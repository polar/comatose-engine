# load everything in /config/initializers
# initializers in your root 'initializers' directory will take precedence if they have the same file name

Dir["#{RAILS_ROOT}/vendor/plugins/comatose_engine/config/initializers/**/*.rb"].each do |initializer|
  load(initializer) unless File.exists?("#{RAILS_ROOT}/config/initializers/#{File.basename(initializer)}")
end
