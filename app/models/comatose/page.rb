module Comatose
  # ComatosePage attributes
  #  - mount
  #  - parent_id
  #  - title
  #  - full_path
  #  - slug
  #  - keywords
  #  - body
  #  - filter_type
  #  - position
  #  - version
  #  - updated_on
  #  - created_on
  #    photo
  #
  # TODO: MongoMapper, Mongoid, DataMapper
  #   We need versions of acts_as_versioned, act_as_list, and acts_as_tree to work with those.
  #
  class Page < ActiveRecord::Base
    include ActsAsTree

    # This declaration allows liquid to call these methods as if it were a Liquid::Drop.
    liquid_methods :children, :photo, :title, :keywords, :slug, :position,
                   :created_on, :updated_on, :full_path, :url, :next, :prev, :body, :content, :link


    # We do not allow mass assignment of the mount.
    attr_accessible :parent_id, :title, :full_path, :keywords, :slug, :body, :filter_type, :position,
                    :created_on, :updated_on, :created_at, :updated_at

    # PaperClip for PagePhotos.
    has_attached_file :photo,
                      :default_url => "",
                      :path => ":rails_root/public/system/:attachment/:id/:style/:filename",
                      :url  => "/system/:attachment/:id/:style/:filename"
    attr_accessible :photo, :photo_file_name, :photo_content_type, :photo_file_size, :photo_updated_at

    # Only versions the page according the significant content.
    # We don't do the photo, because it may have been deleted.
    acts_as_versioned :table_name => 'comatose_page_versions',
                      :if_changed =>
                          [:title, :slug, :keywords, :body]

    acts_as_tree :order => "position, title"

    # Scope includes the mount. It really is implied by the parent, but the parent can be nil.
    acts_as_list :scope => [:parent_id, :mount]

    # This "magic" is needed in case the slug was updated and the controller changed the full path.
    # We'll allow this one, since we don't want to do this action unless we know the save was successful.
    after_save :update_children_full_path

    before_create do |record|
      record.created_on = record.updated_on = Time.now
    end

    validates_presence_of :title, :message => "must be present"
    validates_uniqueness_of :slug, :scope => [:parent_id, :mount], :message => "is already in use"

    # Tests Liquid processing of content..
    validates_each :body, :allow_nil => true, :allow_blank => true do |record, attr, value|
      begin
        body_html = record.to_html
      rescue SyntaxError => boom
        record.errors.add :body, "syntax error: #{boom.to_s.gsub('<', '&lt;')}"
      rescue
        record.errors.add :body, "content error: #{boom.to_s.gsub('<', '&lt;')}"
      end
    end

    # Make sure the parent is the same mount.
    validates_each :parent_id, :allow_nil => true do |record, attr, value|
      if record.parent_id
        p = Comatose::Page.where(:id => record.parent_id).first
        if !p
          record.errors.add :parent_id, "invalid parent"
        elsif p.mount != record.mount
          record.errors.add :parent_id, "parent mount mismatch"
        end
      end
    end

    # Returns a pages canonical url.
    def url
      res = "#{self.mount}/#{self.full_path}".squeeze("/")
      res
    end

    # Returns the page before this one that is relative to its parent.
    def prev
      self.higher_item
    end

    # Returns the page after this one that is relative to its parent.
    def next
      self.lower_item
    end

    # Check if a page has a selected keyword. Kewords are not case sensitive.
    # The keyword McCray is the same as mccray.
    def has_keyword?(keyword)
      @key_list ||= (self.keywords || '').downcase.split(',').map { |k| k.strip }
      @key_list.include? keyword.to_s.downcase
    rescue
      false
    end

    # Returns a host relative url for the page.
    def link
      "/#{self.mount}/#{self.id}".squeeze("/")
    end

    # Returns the page's content, transformed and filtered...
    def content
      text        = self.body
      binding     = Comatose::ProcessingContext.new(self, {})
      TextFilters.transform(text, binding, self.filter_type)
    end

    # Returns the page's content, transformed and filtered...
    def to_html(options={ })
      #version = options.delete(:version)
      text        = self.body
      binding     = Comatose::ProcessingContext.new(self, options)
      TextFilters.transform(text, binding, self.filter_type)
    end

    # Returns a Page with a matching path.
    def self.find_by_path(mount, path)
      path = path.split('.')[0].squeeze("/") unless path.empty? # Will ignore file extension...
      self.where(:mount => mount, :full_path => path).first
    end

    # CUpdates the full_path with a url based on the Page tree.
    def update_full_path
      if parent_node = self.parent
        # Build url Path
        path           = "#{parent_node.full_path}/#{self.slug}".squeeze("/")
        self.full_path = path || ""
      else
        # This is a root, the path is blank.
        self.full_path = ""
      end
    end

    protected

    def update_full_path!
      self.class.set_full_path(self)
      save
    end

    # Updates all this page's child url paths if this page's slug has been changed.
    def update_children_full_path(should_save=true)
      if full_path_changed? or slug_changed?
        for child in self.children
          child.update_full_path! unless child.frozen?
          child.update_children_full_path(should_save)
        end
      end
    end
  end
end
