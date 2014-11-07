class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new # guest user (not logged in)

    ###########################################
    # Super Admin Rules
    can :manage, Business if user.roles? :super_business_editor
    can :read,   Business if user.roles? :super_business_viewer


    ###########################################
    # Business Admin Rules
    if user.roles? :admin
      can :manage, Business, { id: user.business_id }
      can :manage, Number, { business_id: user.business_id }
      can :manage, Office, { business_id: user.business_id }
    end

    if user.roles? :schedule_manager
    end

    if user.roles? :schedule_viewer
    end

    if user.roles? :appointment_manager
    end

    if user.roles? :appointment_viewer
    end

    # Users can all read their own Business
    can :read, Business, { id: user.business_id }

  end
end
