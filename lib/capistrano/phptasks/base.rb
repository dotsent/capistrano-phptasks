require 'capistrano/phptasks/common'

configuration = Capistrano::Configuration.respond_to?(:instance) ?
  Capistrano::Configuration.instance(:must_exist) :
  Capistrano.configuration(:must_exist)

configuration.load do

    namespace :deploy do
        after "deploy:finalize_update", "deploy:write_version"
      
        task :start, :roles => :app do
    
        end
    
        task :stop, :roles => :app do
    
        end
    
        task :restart, :roles => :app do
            # no restart required for Apache/mod_php
        end

        # Override internal task
        task :finalize_update, :except => { :no_release => true } do
            run "chmod -R g+w #{latest_release}" if fetch(:group_writable, true)
        	
            # mkdir -p is making sure that the directories are there for some SCM's that don't
            # save empty folders
            run <<-CMD
                rm -rf #{latest_release}/logs &&
                ln -s #{shared_path}/logs #{latest_release}/logs
            CMD
        
            #if fetch(:normalize_asset_timestamps, true)
            #  stamp = Time.now.utc.strftime("%Y%m%d%H%M.%S")
            #  asset_paths = %w(images css js).map { |p| "#{latest_release}/public/#{p}" }.join(" ")
            #  run "find #{asset_paths} -exec touch -t #{stamp} {} ';'; true", :env => { "TZ" => "UTC" }
            #end
        end
        
        # Write :branch variable contents into VERSION file to identify deployed revision
        task :write_version do
            run "echo '#{branch}' > #{latest_release}/VERSION"
        end
    end
end

