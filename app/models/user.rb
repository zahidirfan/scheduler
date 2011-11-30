class User < ActiveRecord::Base
  authenticates
  has_many :candidates
  has_many :interviews
  has_many :comments

  # attr_accessor :password, :password_confirmation
  attr_accessible :name, :username, :type, :email, :password, :password_confirmation

  validates :name, :email, :password, :password_confirmation, :presence => true
  validates :password, :confirmation => true
  validates :password, :length => { :minimum => 6 }

  scope :interview_panel, where(:type => INTERVIEW_PANEL_USER_TYPES)
  scope :current_user, lambda { |user_id| where("id = ?", user_id) }

  def admin?
    false
  end

end
