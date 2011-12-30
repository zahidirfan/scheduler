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

ssh_options[:keys] = %w(/Users/paddy/.ssh/id_rsa)
set :ssh_options, { :forward_agent => true }
set :rails_env, "production"
set :keep_releases, 2
set :branch, "master"
set :user, "root"
set :use_sudo, false
default_run_options[:pty] = true 

#############################################################
#	Servers
#############################################################

role :app, "184.73.50.160"
role :web, "184.73.50.160"
role :db,  "184.73.50.160", :primary => true


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
  task :after_update_code do
    run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
    run "ln -nfs #{shared_path}/log/production.log #{release_path}/config/production.log"
  end  
  
  desc "Restarting mod_rails with restart.txt"
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "touch #{current_path}/tmp/restart.txt"
  end

  [:start, :stop].each do |t|
    desc "#{t} task is a no-op with mod_rails"
    task t, :roles => :app do ; end
  end
  
  task :bundle_install do
    run("cd #{deploy_to}/current && bundle unlock && bundle install")
  end
  
  task :precompile_assets do
    raise "Rails environment not set" unless rails_env
    task = "assets:precompile"
    run "cd #{release_path} && bundle exec rake #{task} RAILS_ENV=#{rails_env}"
  end
  
end


after "deploy", "deploy:after_update_code"
after "deploy:after_update_code", "deploy:bundle_install"
after "deploy:bundle_install", "deploy:cleanup"
after "deploy:cleanup", "deploy:migrate"
after "deploy:migrate", "deploy:precompile_assets"
after "deploy:precompile_assets", "deploy:restart"