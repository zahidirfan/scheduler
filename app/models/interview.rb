class Interview < ActiveRecord::Base
  include CalendarInvite
  belongs_to :candidate
  belongs_to :user
  has_many :comments, :dependent => :destroy

  before_save :update_schedule
  after_save :update_candidate_status

  validates :scheduled_at, :presence => true

  def update_schedule
    self.schedule_time = self.scheduled_at.strftime("%I:%M %p")
    default_endtime = self.scheduled_at.advance(:minutes => 30)
    self.endtime = default_endtime if (self.endtime.nil? || self.endtime < default_endtime)
  end

  def update_candidate_status
    self.candidate.update_attribute("status", "Scheduled")
  end

  def send_notification_to_followers(mail)
    followers = self.candidate.user_followers
    followers.each do |user|
      Notifier.delay.mail(self)
    end
  end

  after_create do |interview|
#    interview.send_notification_to_followers(interview_schedule_mail)
    make_ical(interview)
    Notifier.delay.interview_schedule_mail(interview)
#    Notifier.interview_schedule_mail(interview).deliver
    followers = interview.candidate.user_followers
    followers.each do |user|
      Notifier.delay.interview_schedule_mail(interview, user, false)
    end
  end

  after_update do |interview|
    make_ical(interview)
    if interview.user_id != interview.user_id_was
    Notifier.delay.interview_cancel_mail(interview.user_id_was,interview.candidate.name,interview.formated_scheduled_at(scheduled_at_was))
    Notifier.delay.interview_schedule_mail(interview)
    else
    Notifier.delay.interview_reschedule_mail(interview)
    end
    followers = interview.candidate.user_followers
    followers.each do |user|
      Notifier.delay.interview_reschedule_mail(interview, user, false)
    end
  end

#  after_destroy do |interview|
#    Notifier.delay.interview_cancel_mail(interview.user_id,interview.candidate.name,interview.formated_scheduled_at)
#    followers = interview.candidate.user_followers
#    followers.each do |user|
#      Notifier.delay.interview_cancel_mail(interview.user_id,interview.candidate.name,interview.formated_scheduled_at, user)
#    end
#  end

  scope :dummy, where("1 = 1")
  scope :uncancelled, joins("LEFT OUTER JOIN comments ON comments.interview_id = interviews.id").where("status is null or status != 'Cancelled'")
  scope :by_date, lambda { |date| where("scheduled_at like '#{date}%'").uncancelled.order("schedule_time") }
  scope :upcoming, where("scheduled_at  >= ? ", Time.now).uncancelled.order("scheduled_at, schedule_time")
  scope :this_week, where("scheduled_at > ? and scheduled_at <= ?", Date.today, Date.today.end_of_week).uncancelled.order("scheduled_at,schedule_time")
  scope :this_month, where("scheduled_at > ? and scheduled_at <= ?", Date.today.end_of_week, Date.today.end_of_month).uncancelled.order("scheduled_at,schedule_time")
  scope :fetch_interviews, lambda { |start, endtime| where("scheduled_at between ? and ? ", Time.at(start.to_i).to_formatted_s(:db), Time.at(endtime.to_i).to_formatted_s(:db)).uncancelled
 }
  scope :by_user_id, lambda { |user_id| where("interviews.user_id = ?", user_id).uncancelled }

  def formated_scheduled_at(date_time=nil)
    date_time ||= self.scheduled_at
    date_time.strftime("%b %d, %Y %I:%M %P") unless date_time.nil?
  end

  def formated_schedule_endtime(date_time=nil)
    date_time ||= self.endtime
    date_time.strftime("%b %d, %Y %I:%M %P") unless date_time.nil?
  end
end
