class User < ActiveRecord::Base
  authenticates
  has_many :candidates
  has_many :interviews, :dependent => :destroy
  has_many :comments, :dependent => :destroy

  # attr_accessor :password, :password_confirmation
  attr_accessible :name, :username, :type, :email, :password, :password_confirmation

  validates :name, :email, :presence => true
  validates :password, :password_confirmation, :presence => true, :on => :create
  validates :password, :confirmation => true
  validates :password, :length => { :minimum => 6 }, :allow_blank => true

  scope :interview_panel, where(:type => INTERVIEW_PANEL_USER_TYPES)
  scope :current_user, lambda { |user_id| where("id = ?", user_id) }

  acts_as_follower

  def admin?
    false
  end

  def self.inherited(child)
    child.instance_eval do
      def model_name
        User.model_name
      end
    end
    super
  end

end
