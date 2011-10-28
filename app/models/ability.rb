class Ability
  include CanCan::Ability

  def initialize(user)
    unless user.nil?
      if ["Hr","Administrator"].include?(user.type.to_s)
        can :manage, :all
      end

      if user.type.to_s == "Interviewer"
        can [:read, :create, :update], Comment, :user_id => user.id
      end
    end
  end
end
