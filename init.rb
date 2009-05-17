require 'comatose'
require 'comatose_engine'

#hack the desert plugin to allow generating plugin migrations
Desert::Plugin.class_eval do
  def latest_migration
    migrations.last
  end

  # Returns the version numbers of all migrations for this plugin.
  def migrations
    migrations = Dir[migration_path+"/*.rb"]
    migrations.map { |p| File.basename(p).match(/0*(\d+)\_/)[1].to_i }.sort
  end
end

# Fix Desert's 'current_version' which tries to order by version desc, but version is a string type column, so it breaks
# sort the rows in ruby instead to make sure we get the highest numbered version
Desert::PluginMigrations::Migrator.class_eval do
  class << self
    def current_version #:nodoc:
      result = ActiveRecord::Base.connection.select_values("SELECT version FROM #{schema_migrations_table_name} WHERE plugin_name = '#{current_plugin.name}'").map(&:to_i).sort.reverse[0]
      if result
        result
      else
        # There probably isn't an entry for this plugin in the migration info table.
        0
      end
    end
  end
end

