class Interview < ActiveRecord::Base
  belongs_to :candidate
  belongs_to :user
  has_many :comments

  before_save :update_schedule
  after_save :update_candidate_status

  validates :scheduled_at, :presence => true

  def update_schedule
    self.schedule_time = self.scheduled_at.strftime("%I:%M:%S %p")
    self.endtime = self.scheduled_at.advance(:minutes => 30)
  end

  def update_candidate_status
    self.candidate.update_attribute("status", "Scheduled")
  end

  after_create do |interview|
    Notifier.delay.interview_schedule_mail(interview)
  end

  after_update do |interview|
    if interview.user_id != interview.user_id_was
    Notifier.delay.interview_cancel_mail(interview.user_id_was,interview.candidate_id,scheduled_at_was,schedule_time_was)
    Notifier.delay.interview_schedule_mail(interview)
    else
    Notifier.delay.interview_reschedule_mail(interview)
    end
  end

  after_destroy do |interview|
    Notifier.delay.interview_cancel_mail(interview.user_id,interview.candidate_id,scheduled_at,schedule_time)
  end

  scope :dummy, where("1 = 1")
  scope :today, where(:scheduled_at => Date.today).order("schedule_time")
  scope :upcoming, where("scheduled_at  >= ? ", Date.today).order("scheduled_at, schedule_time")
  scope :this_week, where("scheduled_at > ? and scheduled_at <= ?", Date.today, Date.today.end_of_week).order("scheduled_at,schedule_time")
  scope :this_month, where("scheduled_at > ? and scheduled_at <= ?", Date.today.end_of_week, Date.today.end_of_month).order("scheduled_at,schedule_time")
  scope :fetch_interviews, lambda { |start, endtime| where("scheduled_at between ? and ? ", Time.at(start.to_i).to_formatted_s(:db), Time.at(endtime.to_i).to_formatted_s(:db))
 }
  scope :by_user_id, lambda { |user_id| where("user_id = ?", user_id) }

  def formated_scheduled_at
    self.scheduled_at.strftime("%d-%m-%Y %I:%M %p") unless self.scheduled_at.nil?
  end

end
