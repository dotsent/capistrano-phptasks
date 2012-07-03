require 'capistrano/phptasks/common'

configuration = Capistrano::Configuration.respond_to?(:instance) ?
  Capistrano::Configuration.instance(:must_exist) :
  Capistrano.configuration(:must_exist)

configuration.load do
    set(:config_scp_destination) { "#{latest_release}/application/configs/" }

    namespace :deploy do
        before "deploy:create_symlink", "deploy:update_config"

        #desc "Update configuration files, keys, etc"
        task :update_config do
        	logger.info "Deploying configuration"

            options = exists?(:config_scp_options) ? config_scp_options : ''

            if !exists?(:config_scp_source)
                abort "config_scp_source not set!"
            end

            run "scp #{options} #{config_scp_source} #{config_scp_destination}"
        end
    end
end

