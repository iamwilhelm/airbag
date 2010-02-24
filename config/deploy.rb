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

  desc "tasks to do after updating the code"
  task :after_update_code, :roles => :app do
    copy_config_file("database.yml")
    copy_config_file("email.yml")
  end
  
  task :after_deploy, :roles => :app do
  end
  
end

