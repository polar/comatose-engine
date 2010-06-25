# ComatoseEngine
module ComatoseEngine

  class << self

    def check_for_pending_migrations
      newest_ce_migration = Desert::Manager.find_plugin('comatose_engine').latest_migration
      current_ce_version  = guess_current_ce_version

      pending = newest_ce_migration - current_ce_version
      if pending > 0
        puts "---"
        puts "[COMATOSE ENGINE] You have #{pending} pending ComatoseEngine migrations:"
        puts "ComatoseEngine is at #{newest_ce_migration}, but you have only migrated it to #{current_ce_version}"
        puts "Please run 'script/generate plugin_migration' AND 'rake db:migrate' before continuing, or you will experience errors."
        puts "---"
      end
    end

    def guess_current_ce_version
      # DUMB: checks your db/migrate and parses out the last ComtaoseEngine migration to find out which version you're at
      last_version =  Dir["#{RAILS_ROOT}/db/migrate/[0-9]*_comatose_engine_to*.rb"].sort.last
      if last_version
        last_version[/.*_comatose_engine_to_version_(\d+)/, 1].to_i
      else
        0
      end
    end

  end

end
