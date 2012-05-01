class Request < ActiveRecord::Base
  belongs_to :interview
  belongs_to :user
  
  after_save do |request|
    Notifier.delay.interview_request_mail(request)
  end
end
