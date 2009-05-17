# Load everything in /engine_config/initializers
# Initializers in your root 'initializers' directory will take precedence if they have the same file name

Dir["#{RAILS_ROOT}/vendor/plugins/comatose_engine/config/initializers/**/*.rb"].each do |initializer|
  load(initializer) unless File.exists?("#{RAILS_ROOT}/config/initializers/#{File.basename(initializer)}")
end

ComatoseEngine.check_for_pending_migrations

