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
        
        # Write :branch variable contents into VERSION file to identify deployed revision
        task :write_version do
            if (exists?(:deploy_version))
                run "echo '#{deploy_version}' > #{latest_release}/VERSION"
            else
                run "cp #{latest_release}/REVISION #{latest_release}/VERSION"
            end
        end
    end
end

