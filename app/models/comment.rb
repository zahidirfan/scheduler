class Comment < ActiveRecord::Base

  belongs_to :interview
  belongs_to :candidate
  belongs_to :user

  attr_accessor :status_value
  after_save do |comment|
    comment.candidate.update_attribute(:status, comment.status_value) unless comment.status_value.blank?
    comment.interview.update_attribute(:status, comment.status_value) unless comment.status_value.blank?
    Notifier.delay.interview_feedback_mail(comment)
    Notifier.delay.interview_feedback_mail(comment, comment.interview.scheduler)
    followers = comment.candidate.user_followers
    followers.each do |user|
      Notifier.delay.interview_feedback_mail(comment, user)
    end
  end

  scope :filter_by_user, lambda { |user_id| where("user_id = ?", user_id) }


  def helpers
    ActionController::Base.helpers
  end

end
