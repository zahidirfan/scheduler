class Interview < ActiveRecord::Base
  scope :today, where(:scheduled_at => Date.today)
  scope :this_week, where("scheduled_at <= ?", Date.today.end_of_week)
  scope :this_month, where("scheduled_at <= ?", Date.today.end_of_month)
end
