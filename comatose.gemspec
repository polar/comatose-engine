$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "comatose/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "comatose"
  s.version     = Comatose::VERSION
  s.authors     = ["Dr. Polar Humenn"]
  s.email       = ["polar.humenn@gmail.com","polar@adiron.com"]
  s.homepage    = "http://github.com/polar/comatose-engine"
  s.summary     = "HTML CMS Rails Embeddable Engine"
  s.description = "HTML Content Management System"

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 3.2.0"
  s.add_dependency "jquery-rails"
  s.add_dependency "acts_as_tree", "~> 1.1.0"
  s.add_dependency "acts_as_versioned", "~> 0.6.0"
  s.add_dependency "responds_to_parent", "~> 1.1.0"
  s.add_dependency "paperclip", "~> 3.2.0"
  s.add_dependency "RedCloth", "~> 4.2.0"
  s.add_dependency "liquid", "~> 2.4.0"
  s.add_dependency "client_side_validations", "~> 3.1.0"
  s.add_dependency "remotipart", "~> 1.0.0"
end
