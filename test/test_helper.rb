ENV["RAILS_ENV"] = 'test'

if "plugins" == File.basename(File.expand_path(File.join(File.dirname(__FILE__),"../..")))  
  RAILS_ROOT = File.expand_path(File.join(File.dirname(__FILE__),"../../../"))
else
  RAILS_ROOT = File.expand_path(File.join(File.dirname(__FILE__), "../"))
end

require "#{RAILS_ROOT}/config/environment.rb"

require 'test_help'

class ActiveSupport::TestCase

  self.fixture_path = File.expand_path( File.join(File.dirname(__FILE__), 'fixtures') )

  self.use_transactional_fixtures = true
  self.use_instantiated_fixtures  = false
  
  def setup
    Comatose.configure do |config|
      config.default_filter      = :textile
      config.default_processor   = :liquid
      config.authorization       = Proc.new { true }
      config.admin_authorization = Proc.new { true }
      config.admin_get_author    = Proc.new { request.env['REMOTE_ADDR'] }
      config.admin_get_root_page = Proc.new { ComatosePage.root }
    end
    TextFilters.default_filter = "Textile"
  end

  def create_page(options={})
    ComatosePage.create({ :title => 'Comatose Page', :author=>'test', :parent_id=>1 }.merge(options))
  end
  
  def comatose_page(sym)
    ComatosePage.find_by_slug(sym.to_s.dasherize)
  end
  
  def assert_difference(object, method = nil, difference = 1)
    initial_value = object.send(method)
    yield
    assert_equal initial_value + difference, object.send(method), "#{object}##{method}"
  end

  def assert_no_difference(object, method, &block)
    assert_difference object, method, 0, &block
  end



  class << self
    def should(behave,&block)
      method_name = "test_should_#{behave.gsub(' ', '_')}"
      if block
        define_method method_name, &block
      else
        puts ">>> Untested: #{name.sub(/Test$/,'')} should #{behave}"
      end
    end
  end
end
