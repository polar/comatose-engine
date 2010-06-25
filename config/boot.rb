# load everything in /config/initializers
# initializers in your root 'initializers' directory will take precedence if they have the same file name

Dir["#{RAILS_ROOT}/vendor/plugins/comatose_engine/config/initializers/**/*.rb"].each do |initializer|
  load(initializer) unless File.exists?("#{RAILS_ROOT}/config/initializers/#{File.basename(initializer)}")
end

ComatoseEngine.check_for_pending_migrations

if AppConfig.theme
  theme_view_path = "#{RAILS_ROOT}/themes/#{AppConfig.theme}/views"
  ActionController::Base.view_paths = ActionController::Base.view_paths.dup.unshift(theme_view_path)
end


# We are using Desert, so EnginesHelper is irrelevent
#EnginesHelper::Assets.propagate if EnginesHelper.autoload_assets
 
# # If the app is using Haml/Sass, propagate sass directories too
# EnginesHelper::Assets.update_sass_directories
