$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "comatose/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "comatose"
  s.version     = Comatose::VERSION
  s.authors     = ["Polar Humenn"]
  s.email       = ["polar@syr.edu"]
  s.homepage    = "http://github.com/polar"
  s.summary     = "CMS Rails Embeddable Engine"
  s.description = "Content Management System"

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 3.2.0"
  s.add_dependency "jquery-rails"

  s.add_development_dependency "sqlite3"
end
