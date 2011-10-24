class User < ActiveRecord::Base
  
  authenticates
  validates :name, :email, :presence => true
  
  has_many :candidates
  has_many :interviews
  has_many :comments
  
  
  def admin?
    false
  end
  
  def self.interview_panel
    Interviewer.all + Bm.all + Hr.all
  end
    
end
