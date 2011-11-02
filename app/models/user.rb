class User < ActiveRecord::Base
  authenticates
  has_many :candidates
  has_many :interviews
  has_many :comments

  attr_accessor :password, :password_confirmation

  validates :name, :email, :password, :password_confirmation, :presence => true
  validates :password, :confirmation => true
  validates :password, :length => { :minimum => 6 }
  def admin?
    false
  end

  def self.interview_panel
    Interviewer.all + Bm.all + Hr.all
  end

end
