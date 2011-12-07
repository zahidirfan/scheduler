class Candidate < ActiveRecord::Base

  acts_as_taggable_on :tags

  has_attached_file :resume, :content_type => 'image/jpeg'
  validates_attachment_presence :resume
  validates_attachment_content_type :resume, :content_type => [ 'application/pdf', 'application/ms-word', "application/rtf"]
  validates_attachment_size :resume, :less_than => 2.megabytes
  validates :name, :presence => true

  has_many :interviews
  belongs_to :user
  #belongs_to :status

  scope :active, where("status !=  'Archive' or status is null")

end
