#
# This file sets up a rails directory for the comatose_engine desert plugin
# for testing and the necessary environmental modifications for 
# its initial installation into a rails app.
#

def say(message)
  puts " [CE SETUP] #{message} \n "
end

def checkout_ce_branch(branch)
  inside 'vendor/plugins/comatose_engine' do
    say "Checking out the #{branch} branch"
    run "git checkout --track -b #{branch} origin/#{branch}"
  end
end

def modify_environment_files
  in_root do
    say "Modifying the environment.rb and environments files to work with Comatose Engine"
    
    # Add "require 'desert' after boot line
    sentinel = "require File.join(File.dirname(__FILE__), 'boot')"
    desert_require = "require 'desert'"
    gsub_file 'config/environment.rb', /(#{Regexp.escape(sentinel)})/mi do |match|
      "#{match}\n #{desert_require}\n"
    end

    # Add required Gems
    gem 'desert', :lib => 'desert'
    gem 'rmagick', :lib => 'RMagick'
    gem 'acts_as_list'
    gem 'acts_as_tree'

    # Add plugin configuration.
    ce_plugins_config = <<EOF
config.plugins = [:comatose_engine, :all]
config.plugin_paths += ["\#{RAILS_ROOT}/vendor/plugins/comatose_engine/plugins"]
EOF
    # Modify the environment.rb file
    environment ce_plugins_config

    ce_boot_line = "\n require \"\#{RAILS_ROOT}/vendor/plugins/comatose_engine/config/boot.rb\""
    append_file 'config/environment.rb', ce_boot_line
  end
end


#########################################
#
# ComatoseEngine Setup

# Comatose Engine Git Repository
ce_git_repo = "git://github.com/polar/comatose-engine.git"

# We have already initialized the root rails directory
# Now let's install the Comatose Engine Plugin

# Set up git repository
git :init
git :add => '.'

# Set up .gitignore files
  run "touch tmp/.gitignore log/.gitignore vendor/.gitignore"
  run %{find . -type d -empty | grep -v "vendor" | grep -v ".git" | grep -v "tmp" | xargs -I xxx touch xxx/.gitignore}
  file '.gitignore', <<-END
.DS_Store
log/*.log
tmp/**/*
config/database.yml
db/*.sqlite3
END

# Install all required gems
rake('gems:install', :sudo => false)

# Install the public as a Git submodule
plugin 'comatose_engine', :git => ce_git_repo, :submodule => true

# Initialize submodules
git :submodule => "init"
git :submodule => "update"
# checkout_ce_branch('edge')

# Add CE routes
route "map.routes_from_plugin :comatose_engine"

modify_environment_files

# Delete app files
run "rm public/index.html"
run "rm public/favicon.ico"

# Set up the Comatose Migration for this app directory.
# We are currently at level 8
file "db/migrate/#{Time.now.strftime("%Y%02m%02d%02H%02m%02S")}_update_comatose_plugin.rb", <<EOF
class UpdateComatosePlugin < ActiveRecord::Migration
  def self.up
    migrate_plugin "comatose_engine", 8
  end

  def self.down
    migrate_plugin "comatose_engine", 0
  end
end
EOF

# Create and Migrate Database
rake('db:create:all')
rake('db:migrate')

# Capastrano?
# capify!

# Commit all work so far to the repository
git :add => '.'
git :commit => "-a -m 'Initial commit'"

# Success!
puts "SUCCESS!"
puts "Run `rake test` and `rake comatose_engine:test` and make sure all tests pass. "
