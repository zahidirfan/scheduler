class Interview < ActiveRecord::Base
  belongs_to :candidate
  has_many :comments

  after_save :update_candidate_status
  def update_candidate_status
    self.candidate.update_attribute("status", "Scheduled")
  end

  after_create do |interview|
    Notifier.delay.interview_schedule_mail(interview)
  end

  after_update do |interview|
    if interview.user_id != interview.user_id_was
    Notifier.delay.interview_cancel_mail(interview,false)
    Notifier.delay.interview_schedule_mail(interview)
    else
    Notifier.delay.interview_reschedule_mail(interview)
    end
  end

  after_destroy do |interview|
    Notifier.delay.interview_cancel_mail(interview,true)
  end

  scope :dummy, where("1 = 1")
  scope :today, where(:scheduled_at => Date.today).order("schedule_time")
  scope :upcoming, where("scheduled_at  >= ? ", Date.today).order("scheduled_at, schedule_time")
  scope :this_week, where("scheduled_at > ? and scheduled_at <= ?", Date.today, Date.today.end_of_week).order("scheduled_at,schedule_time")
  scope :this_month, where("scheduled_at > ? and scheduled_at <= ?", Date.today.end_of_week, Date.today.end_of_month).order("scheduled_at,schedule_time")

end
