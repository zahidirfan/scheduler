class Interviewer < ActiveRecord::Base
  belongs_to :interview
  belongs_to :user
  has_many :comments, :foreign_key => 'user_id'


end
