namespace :db do
  require "faker"
  require "common_app_methods"
  include CommonAppMethods
  namespace :populate do
  task :users => :environment do
    passwd = 'password'
    user_types = user_roles_hash.values.delete("Administrator")
    2.times do
      name = Faker::Internet.user_name
#      email = Faker::Internet.email
      email = name+"@imaginea.com"
      type = user_types.sample
      User.create!(:name => name, :username => name, :email => email, :password => passwd, :password_confirmation => passwd, :type => type)
      puts "Created User (username: #{name}, password: #{passwd})."
    end
  end

    task :candidates => :environment do
# Create Candidates
      2.times do
        name = Faker::Internet.user_name
        email = Faker::Internet.email
        mobile = Faker::PhoneNumber.numerify('##########')
        phone = Faker::PhoneNumber.numerify('####-########')
        priority_id = rand(3)
        subject = Faker::Lorem.sentences(1).first
        resume = File.open(Dir.glob(File.join(Rails.root, 'public','sample_resumes','*')).sample)
        Candidate.create!(:name => name, :email => email, :mobile => mobile, :phone => phone, :priority_id => priority_id, :resume => resume, :subject => subject)
        puts "Candidate Created (Name: #{name})."
      end
    end

    desc "Populate Users, Candidates, Interviews into database"
    task :interviews => ["users","candidates"] do
    # Create Interviews
      2.times do
        scheduled_at = rand_time(Time.now.advance(:days => -30), Time.now.advance(:days => 30))
        user_id = User.random_record.first.id
        candidate_id = Candidate.random_record.first.id
        Interview.create!(:scheduled_at => scheduled_at, :user_id => user_id, :candidate_id => candidate_id)
      end
      puts "Users, Candidates, Interviews are populated into database."
    end
  end
end

def rand_time(from, to)
  Time.at(rand_in_range(from.to_f, to.to_f))
end

def rand_in_range(from, to)
  rand * (to - from) + from
end

