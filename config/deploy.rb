require 'lib/dynamic_errors'

## application settings
set :application, "graphbug"

## repo settings
set :scm, "git"
set :repository,  "git@github.com:iamwilhelm/airbag.git"
set :branch, "master"
set :deploy_via, :remote_cache
set :scm_verbose, true
set :scm_passphrase, ""
set :git_enable_submodules, 1
ssh_options[:forward_agent] = true

## server settings
set :domain, "#{application}.com"
set :slicehost_server, "67.207.140.138"
set :slicehost_user, "wil"
set :slicehost_home, "/home/#{slicehost_user}"

## authentication settings
set :use_sudo, false
set :user, slicehost_user
default_run_options[:pty] = true
ssh_options[:port] = 22

## deploy target settings
set :home, slicehost_home
set :app, "#{home}/public_html/#{domain}/#{application}/"
set :deploy_to, app

role :app, slicehost_server
role :web, slicehost_server
role :db,  slicehost_server, :primary => true

def copy_config_file(filename)
  config_path = "#{home}/etc/#{domain}/#{filename}"
  run "cp #{config_path} #{release_path}/config/#{filename}"
end

def link_to(shared_path, link_path)
  run "ln -nfs #{File.join(deploy_to,shared_path)} #{File.join(release_path,link_path)}"
end

# server setup tasks
namespace :deploy do 

  desc "Restart apache mod_rails"
  task :restart do
    run "cd #{deploy_to}/current && touch tmp/restart.txt"
  end
  
  desc "Start mod_rails restarts"
  task :start do
    restart
  end

  desc "Stop mod_rails not applicable"
  task :stop do; end

  desc "Copy configuration files from server to app's config directory"
  task :copy_config, :roles => :app do
    copy_config_file("database.yml")
    copy_config_file("email.yml")
  end
end
after "deploy:update_code", "deploy:copy_config"


# TODO move this to a dynamic errors plugin or library

# Set the following in apache in order for it to work:
#
# ErrorDocument 503 /system/maintenance.html
# RewriteEngine On
# RewriteCond %{REQUEST_URI} !\.(css|jpg|png)$
# RewriteCond %{DOCUMENT_ROOT}/system/maintenance.html -f
# RewriteCond %{SCRIPT_FILENAME} !maintenance.html
# RewriteRule ^.*$ /system/maintenance.html [redirect=503,last]
#
namespace :deploy do
  namespace :web do
    task :disable, :roles => :web do
      on_rollback { rm "#{deploy_to}/system/maintenance.html" }
      maintenance = DynamicErrors.render_503(ENV["UNTIL"], ENV["REASON"])
      put maintenance, File.join(deploy_to, "shared", "system", "maintenance.html"), :mode => 0644
    end
  end
end
