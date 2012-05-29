require 'capistrano/phptasks/base'
require 'capistrano/phptasks/common'

configuration = Capistrano::Configuration.respond_to?(:instance) ?
  Capistrano::Configuration.instance(:must_exist) :
  Capistrano.configuration(:must_exist)

configuration.load do    
  _cset(:php_bin,  "php")
  set(:composer_bin) { "#{shared_path}/composer.phar" }

  # Dirs that need to remain the same between deploys (shared dirs)
  _cset(:shared_children,     ["library", "vendor"])

  # Files that need to remain the same between deploys
  set :shared_files,        false

  namespace :composer do
    desc "Download composer.phar"
    task :download do
      if remote_file_exists?("#{composer_bin}")
        logger.info "Won't attempt to download composer.phar as it appears to be downloaded"
      else
        run "wget http://getcomposer.org/composer.phar -q -O #{composer_bin}"
        run "chmod +x #{composer_bin}"
      end
    end
        
    desc "Install packages via composer"
    task :install do
    logger.info "Installing package"
      run "cd #{latest_release} && #{php_bin} -dallow_url_fopen=true #{composer_bin} --no-ansi install"
#&> /dev/null"
    end
    
    desc "Update pyrus packages"
      task :update do
        logger.info "Updating package"
      run "cd #{latest_release} && #{php_bin} -dallow_url_fopen=true #{composer_bin} --no-ansi update"
#&> /dev/null"
    end
    
    desc "Selfupdate composer.phar"
    task :selfupdate do
      logger.info "Selfupdating composer.phar"
      run "#{php_bin} -dallow_url_fopen=true #{composer_bin} self-update &> /dev/null"
    end

    # deprecated and may be removed in a future releases
    task :share_childs do
      if shared_children
        shared_children.each do |link|
          run "mkdir -p #{shared_path}/#{link}"
          run "if [ -d #{release_path}/#{link} ] ; then rm -rf #{release_path}/#{link}; fi"
          run "ln -nfs #{shared_path}/#{link} #{current_release}/#{link}"
        end
      end
      if shared_files
        shared_files.each do |link|
          link_dir = File.dirname("#{shared_path}/#{link}")
          run "mkdir -p #{link_dir}"
          run "touch #{shared_path}/#{link}"
          run "ln -nfs #{shared_path}/#{link} #{current_release}/#{link}"
        end
      end
    end
  end
end
