class OtherInterviewer < ActiveRecord::Base
  set_table_name 'interviewers'
  belongs_to :interview
  belongs_to :user
  has_many :comments, :foreign_key => 'user_id'
end
