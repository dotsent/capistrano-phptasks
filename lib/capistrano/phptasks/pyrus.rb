require 'capistrano/phptasks/common'

configuration = Capistrano::Configuration.respond_to?(:instance) ?
  Capistrano::Configuration.instance(:must_exist) :
  Capistrano.configuration(:must_exist)

configuration.load do    
    set(:pyrus_bin) { "#{shared_path}/bin/pyrus.phar" }
    set(:pyrus_dir) { "#{shared_path}/pyrus" }

    namespace :deploy do

        before "deploy:install_pkgs", "deploy:install_pyrus"
        after "deploy:install_pyrus", "deploy:discover_channels"

        desc "Install pyrus pear2"
        task :install_pyrus do
            if remote_file_exists?("#{pyrus_bin}")
            	logger.info "Won't attempt to install pyrus as it appears to be installed"
            else
                run "wget http://pear2.php.net/pyrus.phar -q -O #{pyrus_bin}"
                run "chmod +x #{pyrus_bin}"
            end
        end
    
        #desc "Discover pyrus channels"
        task :discover_channels do
            run "#{pyrus_bin} #{pyrus_dir} set auto_discover 1"
        end
    
        desc "Install pyrus packages"
        task :install_pkgs do
            if (exists?(:pyrus_packages))
                pyrus_packages.each do |pkg|
                    logger.info "Installing package #{pkg}"
                    run "#{pyrus_bin} #{pyrus_dir} install #{pkg} &> /dev/null"
                end
            end
        end
    
        desc "Update pyrus packages"
        task :update_pkgs do
            if (exists?(:pyrus_packages))
                pyrus_packages.each do |pkg|
                    logger.info "Updating package #{pkg}"
                    run "#{pyrus_bin} #{pyrus_dir} upgrade #{pkg} &> /dev/null"
                end
            end
        end
    
        desc "Uninstall pyrus packages"
        task :remove_pkgs do
            if (exists?(:pyrus_packages))
                pyrus_packages.each do |pkg|
                    logger.info "Uninstalling package #{pkg}"
                    run "#{pyrus_bin} #{pyrus_dir} uninstall #{pkg} &> /dev/null"
                end
            end
        end

        #desc "Create package symlinks in library/ directory"
        task :pyrus_symlinks do
            if exists?(:pyrus_package_symlinks)
                shared_lib_root = "#{pyrus_dir}/php"
                pkgs, links = '', ''

                pyrus_package_symlinks.each do |pkg|
                    pkgs = pkgs + " #{latest_release}/library/#{pkg}"
                    links = links + "#{shared_lib_root}/#{pkg}"
                end

                links = links + " #{latest_release}/library"
                cmd = "rm -rf #{pkgs} && ln -s #{links}"

                run cmd
            end
        end
    end
end

