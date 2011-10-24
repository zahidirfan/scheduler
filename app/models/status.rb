class Status < ActiveRecord::Base
  validates :name, :uniqueness => true, :presence => true
  #has_many :candidates
end
