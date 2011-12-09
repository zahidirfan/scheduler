class Ability
  include CanCan::Ability

  def initialize(user)
    unless user.nil?
      user_type = user.type.to_s
      if ["Hr","Administrator"].include?(user_type)
        can :manage, :all
        can :assign_role, User
      elsif ["Bm", "Pl"].include?(user_type)
        can [:read, :create, :update], Comment, :user_id => user.id
        can [:read], Interview
        can [:read, :mark_archive], Candidate
        can :password_change, User
        cannot :assign_role, User
        can :update, :user, [:password, :password_confirmation, :commit]
      elsif user_type == "Interviewer"
        can [:read, :create, :update], Comment, :user_id => user.id
        can [:read], Interview
        can :update, :user, [:password, :password_confirmation, :commit]
        cannot :assign_role, User
        can :password_change, User
        can :get_interviews, Interview
      end
    end
  end
end
