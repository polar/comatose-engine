module Comatose
  # ComatosePage attributes
  #  - mount
  #  - parent_id
  #  - title
  #  - full_path
  #  - slug
  #  - keywords
  #  - body
  #  - author
  #  - filter_type
  #  - position
  #  - version
  #  - updated_on
  #  - created_on
  #    page_photo
  class Page < ActiveRecord::Base

    # This method allows liquid to call these methods as if it were a Drop.
    liquid_methods :children, :page_photo, :title, :keywords, :slug, :position,
                   :created_on, :updated_on, :full_path, :uri, :next, :prev, :body, :content


    # We do not allow mass assignment of the mount.
    attr_accessible :parent_id, :title, :full_path, :keywords, :slug, :body, :author, :filter_type, :position,
                    :created_on, :updated_on, :page_photo

    # 0.8 Added support for PaperClip for PagePhotos.
    has_attached_file :page_photo,
                      :default_url => "/assets/comatose/addphoto.jpg",
                      :path => ":rails_root/public/system/:attachment/:id/:style/:filename",
                      :url  => "/system/:attachment/:id/:style/:filename"
    attr_accessible :page_photo_file_name, :page_photo_content_type, :page_photo_file_size, :page_photo_updated_at
    attr_accessible :created_at, :updated_at
    # Only versions the content... Not all of the meta data or position
    acts_as_versioned :table_name => 'comatose_page_versions',
                      :if_changed =>
                          [:title, :slug, :keywords, :body, :page_photo_file_name]

    acts_as_tree :order => "position, title"

    # Scope should include mount, but that is implied by parent, unless parent is null.
    acts_as_list :scope => [:parent_id, :mount]

    # I hate this magic! The controller should take care of this.
    before_save :cache_full_path, :create_full_path
    after_save :update_children_full_path

    # Manually set these, because record_timestamps = false
    before_create do |record|
      record.created_on = record.updated_on = Time.now
    end

    validates_presence_of :title, :message => "must be present"
    validates_uniqueness_of :slug, :scope => [:parent_id, :mount], :message => "is already in use"
    #validates_presence_of :parent_id, :on => :create, :message => "must be present"

    # Tests ERB/Liquid content...
    validates_each :body, :allow_nil => true, :allow_blank => true do |record, attr, value|
      begin
        body_html = record.to_html
      rescue SyntaxError => boom
        record.errors.add :body, "syntax error: #{boom.to_s.gsub('<', '&lt;')}"
      rescue
        record.errors.add :body, "content error: #{boom.to_s.gsub('<', '&lt;')}"
      end
    end

    validates_each :parent_id, :allow_nil => true do |record, attr, value|
      if record.parent_id
        p = Comatose::Page.where(:id => record.parent_id).first
        if !p || p.mount != record.mount
          record.errors.add :parent_id, "invalid parent"
        end
      end
    end

    # Returns a pages URI dynamically, based on the active mount point
    def uri
      (self.mount + self.full_path).squeeze("/")
    end

    def prev
      self.lower_item
    end

    def next
      self.higher_item
    end

    # Check if a page has a selected keyword... NOT case sensitive.
    # So the keyword McCray is the same as mccray
    def has_keyword?(keyword)
      @key_list ||= (self.keywords || '').downcase.split(',').map { |k| k.strip }
      @key_list.include? keyword.to_s.downcase
    rescue
      false
    end

    def content
      text        = self.body
      binding     = Comatose::ProcessingContext.new(self, {})
      filter_type = self.filter_type || '[No Filter]'
      TextFilters.transform(text, binding, filter_type, Comatose.config.default_processor)
    end

    # Returns the page's content, transformed and filtered...
    def to_html(options={ })
      #version = options.delete(:version)
      text        = self.body
      binding     = Comatose::ProcessingContext.new(self, options)
      filter_type = self.filter_type || '[No Filter]'
      TextFilters.transform(text, binding, filter_type, Comatose.config.default_processor)
    end

    # Static helpers...

    # Returns a Page with a matching path.
    def self.find_by_path(mount, path)
      path = path.split('.')[0].squeeze("/") unless path.empty? # Will ignore file extension...
      self.where(:mount => mount, :full_path => path).first
    end

    protected

    # Creates a URI path based on the Page tree
    def create_full_path
      if parent_node = self.parent
        # Build URI Path
        path           = "#{parent_node.full_path}/#{self.slug}".squeeze("/")
        self.full_path = path || ""
      else
        # I'm the root -- My path is blank
        self.full_path = ""
      end
    end

    def create_full_path!
      create_full_path
      save
    end

    # Caches old path (before save) for comparison later
    def cache_full_path
      @old_full_path = self.full_path
    end

    # Updates all this content's child URI paths
    def update_children_full_path(should_save=true)
      # OPTIMIZE: Only update all the children if the :slug/:fullpath is different
      if full_path_changed? or slug_changed?
        for child in self.children
          child.create_full_path! unless child.frozen?
          child.update_children_full_path(should_save)
        end
      end
    end
  end
end
