# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
Resume::Application.initialize!
ActionMailer::Base.smtp_settings = {
  :address              => "smtp.gmail.com",
  :port                 => 587,
  :domain               => "gmail.com",
  :user_name            => "rapbhantest@gmail.com",
  :password             => "zcBV4CdM",
  :authentication       => "plain",
  :enable_starttls_auto => true
}
