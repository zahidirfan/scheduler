class Interview < ActiveRecord::Base
  belongs_to :candidate
  has_many :comments

  before_save :update_schedule
  after_save :update_candidate_status

  def update_schedule
    self.schedule_time = self.scheduled_at.strftime("%I:%M:%S %p")
    self.endtime = self.scheduled_at.advance(:hours => 1)
  end

  def update_candidate_status
    self.candidate.update_attribute("status", "Scheduled")
  end

  scope :dummy, where("1 = 1")
  scope :today, where(:scheduled_at => Date.today).order("schedule_time")
  scope :this_week, where("scheduled_at > ? and scheduled_at <= ?", Date.today, Date.today.end_of_week).order("scheduled_at,schedule_time")
  scope :this_month, where("scheduled_at > ? and scheduled_at <= ?", Date.today.end_of_week, Date.today.end_of_month).order("scheduled_at,schedule_time")

  def formated_scheduled_at
    self.scheduled_at.strftime("%d-%m-%Y %I:%M %p") unless self.scheduled_at.nil?
  end

end
