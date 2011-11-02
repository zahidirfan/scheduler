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
      elsif user.type.to_s == "Interviewer"
        can [:read, :create, :update], Comment, :user_id => user.id
        can [:read], Interview
      end      
    end
  end
end
