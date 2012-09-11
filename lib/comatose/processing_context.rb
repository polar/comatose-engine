
class Comatose::ProcessingContext < Liquid::Context

  class PageFinder
    def initialize(mount)
      @mount = mount
    end

    def [](key)
      Comatose::Page.where(:mount => @mount, :slug => key).first
    end

    def has_key?(key)
      return true
    end

    def to_liquid
      self
    end
  end

  def initialize( page, locals={} )
    @locals = locals.stringify_keys if locals.respond_to? :stringify_keys
    @page = page
    super(@locals, { "page" => @page, "pages" => PageFinder.new(page.mount) }, {}, false)
  end

  def to_liquid
    self
  end

end



