class Interview < ActiveRecord::Base
  include CalendarInvite
  belongs_to :candidate
  belongs_to :user
  belongs_to :scheduler, :class_name => "User"
  has_many :comments, :dependent => :destroy
  has_many :interviewers, :dependent => :destroy

  before_save :update_schedule
  after_save :update_candidate_status

  validates :scheduled_at, :presence => true

  def update_schedule
    self.schedule_time = self.scheduled_at.strftime("%I:%M %p")
    self.endtime = self.scheduled_at.advance(:minutes => 30)
#    self.endtime = default_endtime if self.endtime.nil? || ((self.endtime - default_endtime > 5400) && (default_endtime - self.endtime < 5400))
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

  before_update do |interview|
    make_ical(interview)
    old_changes = {:int_type => interview.interview_type_was, :int_schedule => interview.formated_scheduled_at(scheduled_at_was)}
    new_changes = {:int_type => interview.interview_type, :int_schedule => interview.formated_scheduled_at(scheduled_at)}
    if interview.user_id != interview.user_id_was
    old_interviewers = Interview.find(interview.id).interviewers
    Notifier.interview_cancel_mail(interview.user_id_was, interview.candidate.name, old_changes, old_interviewers).deliver
    Notifier.interview_schedule_mail(interview).deliver
    else
    Notifier.interview_reschedule_mail(interview, new_changes, interview.interviewers).deliver
    end
    followers = interview.candidate.user_followers
    followers.each do |user|
      Notifier.delay.interview_reschedule_mail(interview, new_changes, interview.interviewers, user, false)
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
  scope :later, where("scheduled_at >= ? and scheduled_at < ?", Date.today.next_week, Date.today.end_of_month+1).uncancelled.order("scheduled_at,schedule_time")
  scope :upcoming, where("scheduled_at  >= ? ", DateTime.current).uncancelled.order("scheduled_at, schedule_time")
  scope :this_week, where("scheduled_at > ? and scheduled_at < ?", Date.tomorrow+1, Date.today.end_of_week+1).uncancelled.order("scheduled_at,schedule_time")
  scope :fetch_interviews, lambda { |start, endtime| where("scheduled_at between ? and ? ", Time.at(start.to_i).to_formatted_s(:db), Time.zone.at(endtime.to_i).to_formatted_s(:db)).uncancelled
 }
  scope :by_user_id, lambda { |user_id| where("interviews.user_id = ?", user_id).uncancelled }

  def previous(offset = 0)
    self.class.joins("LEFT OUTER JOIN comments ON comments.interview_id = interviews.id").where("(status is null or status != 'Cancelled') && interviews.id < ? && interviews.candidate_id = ? && scheduled_at < ?", self.id, self.candidate_id, self.scheduled_at).limit(1).offset(offset).order("scheduled_at DESC")
  end

  def formated_scheduled_at(date_time=nil)
    date_time ||= self.scheduled_at
    date_time.strftime("%a, %b %d, %Y %I:%M %P") unless date_time.nil?
  end

  def formated_schedule_endtime(date_time=nil)
    date_time ||= self.endtime
    date_time.strftime("%a, %b %d, %Y %I:%M %P") unless date_time.nil?
  end

  def print_interviewer_names
    self.interviewers.joins(:user).select("users.name").collect(&:name).join(', ')
  end

  def print_interviewer_emailids()
    self.interviewers.joins(:user).select("users.email").collect(&:email).join(', ')
  end

end
