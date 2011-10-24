class Interview < ActiveRecord::Base
  belongs_to :candidate
  has_many :comments
  
  after_save :update_candidate_status
  
  def update_candidate_status
    self.candidate.update_attribute("status", "Scheduled")
  end
  
end
