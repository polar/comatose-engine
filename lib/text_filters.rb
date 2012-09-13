require 'comatose/support/class_options'

class TextFilters
  
  define_option :default_processor, :liquid
  define_option :default_filter,    "Textile"
  define_option :logger,            nil
  
  @registered_filters = {}
  @registered_titles  = {}

  attr_reader :name
  attr_reader :title
  def initialize(name, title)
    @name = name
    @title = title
  end

  # The default create_link method...
  # Override for your specific filter, if needed, in the #define block
  def create_link(title, url)
    %Q|<a href="#{url}">#{title}</a>|
  end
  
  # Process the text with using the specified context
  def process_text(text, context, processor=nil)
    case (processor || TextFilters.default_processor)
    when :erb then process_with_erb(text, context)
    when :liquid then process_with_liquid(text, context)
    else raise "Unknown Text Processor '#{processor.to_s}'"
    end
  end
  
  class << self
    private :new
    attr_reader :registered_filters
    attr_reader :registered_titles
    
    # Use this to create and register your TextFilters
    def define(name, title, &block)
      begin
        p = new(name, title)
        p.instance_eval(&block)
        if p.respond_to? :render_text
          registered_titles[title] = name
          registered_filters[name] = p
        else
          raise "#render_text isn't implemented in this class"
        end
      rescue LoadError => boom
        TextFilters.logger.debug "Filter '#{name}' was not included: #{boom}" unless TextFilters.logger.nil?
      rescue Exception => boom1
        TextFilters.logger.debug "Filter '#{name}' was not included: #{boom1}" unless TextFilters.logger.nil?
      end
    end
    
    def get_filter(name)
      name = TextFilters.default_filter if name.nil?
      name = registered_titles[name] if name.is_a? String
      filter = registered_filters[name]
      raise "No filter found for '#{name}' in registered_titles: #{registered_titles.inspect} or registered_filters: #{registered_filters.inspect}" unless filter
      filter
    end

    def [](name)
      get_filter(name)
    end
    
    def all
      registered_filters
    end
    
    def all_titles
      registered_titles.keys
    end

    def render_text(text, name=nil)
      get_filter(name).render_text(text)
    end

    def process_text(text, context=nil, name=nil, processor=nil)
      get_filter(name).process_text(text, context, processor)
    end

    # Call
    def transform(text, context=nil, name=nil, processor=nil)
      render_text( process_text(text, context, name, processor), name )
    end
  end
  
private

  # This is an instance method so that it won't puke on requiring
  # a non-existent library until it's being registered -- the only
  # place I can really capture the LoadError.
  def require(name)
    Kernel.require name
  end

  # Use Liquid to process text...
  def process_with_liquid(text, context={})
    begin
      context = context.stringify_keys if context.respond_to? :stringify_keys
      Liquid::Template.parse(text).render(context)
    rescue Exception => boom
      raise "Liquid Error: #{boom}"
    end
  end
  
end

Dir[File.join(File.dirname(__FILE__), 'text_filters', '*.rb')].each do |path|
  require "text_filters/#{File.basename(path)}"
end
