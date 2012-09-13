module Comatose

  class Variable < Liquid::Drop

    def initialize(name = nil)
      Comatose.register_variable(name, self) unless name.nil?
    end

    class << self
      def define(name, &block)
        Comatose.registered_drops[name] = Comatose::VariableDynamic.new(&block)
      end

      def define_static(name, &block)
        Comatose.registered_drops[name] = Comatose::VariableStatic.new(block.call(nil))
      rescue Exception => boom
        Rails.logger.debug "Drop '#{name}': bad evaluation: #{boom}"
      end
    end
  end

  class VariableStatic < Variable
    def initialize(val)
      @val = val
    end
    def to_liquid
      @val.to_liquid
    end
  end

  class VariableDynamic < Variable
    def initialize(&block)
      @block = block
    end
    def to_liquid
      @block.call(nil).to_liquid
    end
  end

  class << self

    # Returns/initializes a hash for storing ComatoseDrops
    def registered_drops
      @registered_drops ||= {}
    end

    def register_variable(name, drop)
      raise "Drop is not a Comatose::Variable" unless drop.is_a? Comatose::Variable
      self.registered_drops[name] = drop
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