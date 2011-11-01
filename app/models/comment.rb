class Comment < ActiveRecord::Base
  belongs_to :interview
  belongs_to :candidate
  belongs_to :user
  after_save do |comment|
    Notifier.delay.interview_feedback_mail(comment)
  end
end
