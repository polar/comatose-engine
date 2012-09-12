require "comatose/support/class_options"
module Comatose

  def self.config
    @@config ||= Configuration.new
  end

  def self.configure(&block)
    raise "#configure must be sent a block" unless block_given?
    yield config
    config.validate!
  end

  class Configuration

    attr_accessor_with_default :admin_title,          'Comatose'
    attr_accessor_with_default :admin_sub_title,      'The Micro CMS'
    attr_accessor_with_default :content_type,         'utf-8'
    attr_accessor_with_default :default_filter,       'Textile'
    attr_accessor_with_default :default_processor,    :liquid
    attr_accessor_with_default :hidden_meta_fields,   []


    def initialize
    end

    def validate!
      # Rips through the config and validates it's, er, valid
      true
    end

    class ConfigurationError < StandardError; end

  end

end
