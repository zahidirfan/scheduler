class Candidate < ActiveRecord::Base
  include UserInfo

  before_destroy do |candidate|
    candidate.upcoming_interviewers.each do |user|
      Notifier.delay.candidate_delete_mail(candidate.name, user, current_user)
    end
    followers = candidate.user_followers
    followers.each do |user|
      Notifier.delay.candidate_delete_mail(candidate.name, user, current_user, true)
      user.stop_following(candidate)
    end
  end

  after_update do |candidate|
    followers = candidate.user_followers
    changes = candidate.changes.delete_if {|key, value| ["status", "updated_at"].include?(key)}
    if changes.length > 0
      followers.each do |user|
        Notifier.delay.candidate_profile_update_mail(candidate, user, current_user, changes)
      end
    end
  end

  acts_as_taggable_on :tags
  acts_as_followable

  has_attached_file :resume, :content_type => 'image/jpeg'
  validates_attachment_presence :resume
  validates_attachment_content_type :resume, :content_type => [ 'application/pdf', 'application/msword', 'application/vnd.openxmlformats-officedocument.wordprocessingml.document', "application/rtf"], :message => 'invalid file format'
  validates_attachment_size :resume, :less_than => 2.megabytes
  validates :name, :presence => true

  has_many :interviews, :dependent => :destroy
  has_many :users, :through => :interviews
  #belongs_to :status

  scope :active, where("status !=  'Archive' or status is null")

  def upcoming_interviewers
    self.interviews.upcoming.collect { |i| i.user }
  end

end
