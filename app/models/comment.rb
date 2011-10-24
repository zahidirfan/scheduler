class Comment < ActiveRecord::Base
  belongs_to :interview
  belongs_to :candidate
  belongs_to :user
end
