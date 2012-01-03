class Candidate < ActiveRecord::Base

  acts_as_taggable_on :tags
  acts_as_followable

  has_attached_file :resume, :content_type => 'image/jpeg'
  validates_attachment_presence :resume
  validates_attachment_content_type :resume, :content_type => [ 'application/pdf', 'application/msword', 'application/vnd.openxmlformats-officedocument.wordprocessingml.document', "application/rtf"]
  validates_attachment_size :resume, :less_than => 2.megabytes
  validates :name, :presence => true

  has_many :interviews, :dependent => :destroy
  belongs_to :user
  #belongs_to :status

  after_update do |candidate|
    followers = candidate.user_followers
    followers.each do |user|
      Notifier.delay.candidate_profile_update_mail(candidate, user)
    end
  end

  after_destroy do |candidate|
    followers = candidate.user_followers
    followers.each do |user|
      Notifier.delay.candidate_deleted_mail(candidate, user)
      user.stop_following(candidate)
    end
  end


  scope :active, where("status !=  'Archive' or status is null")

end
