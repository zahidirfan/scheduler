class Interview < ActiveRecord::Base
  belongs_to :candidate
  has_many :comments

  after_save :update_candidate_status
  def update_candidate_status
    self.candidate.update_attribute("status", "Scheduled")
  end

  scope :today, where(:scheduled_at => Date.today)
  scope :this_week, where("scheduled_at <= ?", Date.today.end_of_week)
  scope :this_month, where("scheduled_at <= ?", Date.today.end_of_month)
end
