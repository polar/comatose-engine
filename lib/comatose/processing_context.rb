
class Comatose::ProcessingContext < Liquid::Context

  class PageFinder
    def initialize(mount)
      @mount = mount
    end

    #
    # If there is more than one it returns a collection, otherwise, just one or nil.
    # The user should know these things.
    #
    def [](key)
      if (/\// =~ key)
        match = /^((:?#)([a-zA-Z0-9\-]+))?(\/[a-zA-Z0-9\-\/]+)?/.match key
        if match
          rootslug = match[3]
          path = "/#{match[4]}".squeeze("/")
        end
        if 1 < Comatose::Page.where(:mount => @mount, :full_path => path).count
          pages = Comatose::Page.where(:mount => @mount, :full_path => path).all
          rootslug.nil? ? pages : pages.find {|p| p.root.slug == rootslug }
        else
          Comatose::Page.where(:mount => @mount, :full_path => path).first
        end
      else
        if 1 < Comatose::Page.where(:mount => @mount, :slug => key).count
          Comatose::Page.where(:mount => @mount, :slug => key).all
        else
          Comatose::Page.where(:mount => @mount, :slug => key).first
        end
      end
    end

    def has_key?(key)
      return true
    end

    def to_liquid
      self
    end
  end

  def initialize( page, locals={} )
    @locals = locals.merge(Comatose.registered_drops)
    @locals = @locals.stringify_keys if locals.respond_to? :stringify_keys
    @page = page
    super(@locals, { "page" => @page, "pages" => PageFinder.new(page.mount) }, {}, false)
  end

  def to_liquid
    self
  end

end



