class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new # guest user (not logged in)

    ###########################################
    # Super Admin Rules
    if user.roles? :super_admin
      can :dashboard, Manage
      can :manage, ManageBusiness if user.roles? :super_business_editor
      can :read,   ManageBusiness if user.roles? :super_business_viewer
    end



    ###########################################
    # Business Admin Rules

    if user.roles? :admin
      # Admins can only edit active/approved businesses
      can :manage, Business, is_active: true
    end

    if user.roles? :schedule_manager
    end

    if user.roles? :schedule_viewer
    end

  end
end
