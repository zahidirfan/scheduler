class User < ActiveRecord::Base
  
  authenticates
  validates :name, :email, :presence => true
  
  has_many :candidates
  
  
  def admin?
    false
  end
  
end
