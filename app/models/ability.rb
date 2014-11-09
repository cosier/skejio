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
      # Can manage their own Business
      can :manage, Business, { id: user.business_id }

      # Can manage their own Offices for their associated Business
      can :manage, Office, { business_id: user.business_id }

      # Can manage Numbers belonging to the subaccount which that user has access to.
      can :manage, Number, { sub_account_id: (user.business.sub_account and user.business.sub_account.id) }

      # Can manage Service belonging to the same business
      can :manage, Service, { business_id: user.business_id }

      # Can manage Users belonging to the same Business
      can :manage, User, { business_id: user.business_id }
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
