module Comatose

  class Variable

    attr_accessor :block

    def initialize(&blk)
       @block = blk
    end

    def to_liquid
      drop = Liquid::Drop.new
      drop.instance_eval(block)
      drop
    end

    class << self

      def define(name, &block)
        d = Comatose::Variable.new(&block)
        Comatose.registered_drops[name] = d
      rescue Exception => boom
        Rails.logger.debug "Drop '#{name}' was not included: #{boom}"
      end

      def define_static(name, &block)
        d = Liquid::Drop.new
        d.instance_eval(&block)
        Comatose.registered_drops[name] = d
      rescue Exception => boom
        Rails.logger.debug "Drop '#{name}' was not included: #{boom}"
      end
    end
  end

  class << self

    # Returns/initializes a hash for storing ComatoseDrops
    def registered_drops
      @registered_drops ||= {}
    end

    # Simple wrapper around the ProcessingContext.define method
    # I think Comatose.define_drop is probably simpler to remember too
    def define_drop(name, &block)
      Comatose::Variable.define(name, &block)
    end

    # Registers a 'filter' for Liquid use
    def register_filter(module_name)
      Liquid::Template.register_filter(module_name)
    end

  end
end

module TimeagoFilter
  class Helpers
    extend ActionView::Helpers::DateHelper
  end

  def time_ago(input)
    TimeagoFilter::Helpers.distance_of_time_in_words_to_now( input, true )
  rescue
    #puts "Oops! -- #{$!}"
    input
  end
end

Comatose.register_filter TimeagoFilter