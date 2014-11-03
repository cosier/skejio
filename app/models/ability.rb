class Ability
  include CanCan::Ability

  def initialize(user)
    # Define abilities for the passed in user here. For example:
    #
    user ||= User.new # guest user (not logged in)

    # Check the roles bitmask for inclusion of :admin integer
    if user.roles? :admin
      can :manage, :all
    else
      # Nothing at the moment
    end

  end
end
