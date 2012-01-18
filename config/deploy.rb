#require "bundler/capistrano"

#############################################################
#	Application
#############################################################

set :application, "resume"
set :deploy_to, "/data/www/#{application}"
set :rake, "rake"
set :migrate_target, :latest

#############################################################
#	Settings
#############################################################

ssh_options[:keys] = %w(/Users/gokulamurthy/.ssh/id_rsa)
set :ssh_options, { :forward_agent => true }
set :rails_env, "production"
set :keep_releases, 2
set :branch, "master"
set :user, "root"
set :use_sudo, false
default_run_options[:pty] = true
set :rake, "rake"
set :compile_assets, (ENV['COMPILE_ASSETS'] == 'true')


#############################################################
#	Servers
#############################################################

role :app, "107.22.125.70"
role :web, "107.22.125.70"
role :db,  "107.22.125.70", :primary => true


#############################################################
#	Git
#############################################################

set :repository,  "ssh://rapbhan@gitent-scm.com/git/imaginea/#{application}"
set :repository_cache, "git_cache"
set :deploy_via, :checkout
set :git_shallow_clone, 1
set :scm, :git
set :scm_password, "p@ddy123"

#############################################################
#	Passenger
#############################################################

namespace :deploy do
  desc "Compile asets"
  task :assets do
    if compile_assets
      run "cd #{release_path}; bundle exec rake assets:precompile"
    end
  end

  desc "Updating symlinks"
  task :symlink_shared_paths do
    run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
    run "ln -nfs #{shared_path}/log/production.log #{release_path}/config/production.log"
  end

  task :restart, :roles => :app, :except => { :no_release => true } do
    #do nothing. This is to avoid restart before callbacks. Task deploy, does a restart
  end

  desc "Restarting passenger with restart.txt"
  task :my_restart, :roles => :app, :except => { :no_release => true } do
    run "sudo /etc/init.d/httpd restart"
  end

  desc "Running bundle install"
  task :bundle_install do
    #run "cd #{deploy_to}/current; bundle install;"
  end

  [:start, :stop].each do |t|
    desc "#{t} task is a no-op with mod_rails"
    task t, :roles => :app do ; end
  end

end

namespace :rake do
  desc "Run a task on a remote server."
  # run like: cap rake:invoke task=db:populate
  task :invoke do
    run("cd #{deploy_to}/current; rake #{ENV['task']} RAILS_ENV=#{rails_env}")
  end
end

before "deploy:symlink", "deploy:assets"

after :deploy, "deploy:symlink_shared_paths"
after "deploy:symlink_shared_paths", "deploy:cleanup"
after "deploy:cleanup", "deploy:bundle_install"
#after "deploy:bundle_install", "deploy:migrate"
after "deploy:bundle_install", "deploy:my_restart"


namespace :delayed_job do
  desc "Start delayed_job process"
  task :start, :roles => :app do
    run "cd #{current_path}; RAILS_ENV=#{rails_env} script/delayed_job start"
  end

  desc "Stop delayed_job process"
  task :stop, :roles => :app do
    run "cd #{current_path}; RAILS_ENV=#{rails_env} script/delayed_job stop"
  end

  desc "Restart delayed_job process"
  task :restart, :roles => :app do
    run "cd #{current_path}; RAILS_ENV=#{rails_env} script/delayed_job restart"
  end
end

#after "deploy:start", "delayed_job:start"
#after "deploy:stop", "delayed_job:stop"
#after "deploy:restart", "delayed_job:restart"
