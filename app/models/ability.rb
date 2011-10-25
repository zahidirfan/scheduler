class Ability
  include CanCan::Ability

  def initialize(user)
    if user.type.to_s == "Hr"
      can :manage, :all
    end
    
    if user.type.to_s == "Interviewer"
      can [:read, :create, :update], Comment, :user_id => user.id      
    end
    
  end
end
