source "http://rubygems.org"

# Declare your gem's dependencies in comatose.gemspec.
# Bundler will treat runtime dependencies like base dependencies, and
# development dependencies will be added by default to the :development group.
gemspec

# jquery-rails is used by the dummy application
gem "jquery-rails"

# Declare any dependencies that are still in development here instead of in
# your gemspec. These might include edge Rails or gems from your path or
# Git. Remember to move these dependencies to your gemspec before releasing
# your gem to rubygems.org.

# To use debugger
# gem 'debugger'

gem 'rails', '3.2.8'
gem 'acts_as_list'
gem 'acts_as_tree'
gem 'acts_as_versioned', :git => "git://github.com/technoweenie/acts_as_versioned.git"
gem 'responds_to_parent'
gem 'paperclip'
gem "RedCloth"
gem "liquid"
gem "client_side_validations"
gem "remotipart"

group :test do
  gem "thin"
  gem "test-unit"
  gem "sqlite3"
end

group :development do
  gem "thin"
  gem "debugger"
  gem "sqlite3"
  gem "tinymce-rails"
end
