class Ability
  include CanCan::Ability

  def initialize(user)
    unless user.nil?
      if ["Hr","Administrator"].include?(user.type.to_s)
        can :manage, :all
      elsif user.type.to_s == "Bm"
        can [:read, :create, :update], Comment, :user_id => user.id
        can [:read], Interview
        can [:read], Candidate
        can :password_change, User
        can :update, :user, [:password, :password_confirmation, :commit]
      elsif user.type.to_s == "Interviewer"
        can [:read, :create, :update], Comment, :user_id => user.id
        can [:read], Interview
        can :update, :user, [:password, :password_confirmation, :commit]
        can :password_change, User
      end      
    end
  end
end
