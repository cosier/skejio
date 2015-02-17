class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new # guest user (not logged in)

    ###########################################
    # Super Admin Rules
    can :manage, Business if user.roles? :super_business_editor
    can :read,   Business if user.roles? :super_business_viewer
    binding.pry

    if user.roles? :super_admin
      can :manage, :all
    end

    if user.roles? :super_business_editor
      can :manage, Business
    end

    if user.roles? :super_business_viewer
      can :read, Business
    end

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

      # Can manage Settings belonging to the same Business
      can :manage, Setting, { business_id: user.business_id }
    end

    if user.roles? :schedule_manager or user.roles? :admin
      can :manage, ScheduleRule, { business_id: user.business_id }
      can :manage, TimeEntry, { business_id: user.business_id }

      can :manage, TimeSheet, { business_id: user.business_id }
      can :manage, TimeSheetService, { business_id: user.business_id }

      can :manage, BreakShift, { business_id: user.business_id }
      can :manage, BreakOffice, { business_id: user.business_id }
    end

    if user.roles? :schedule_viewer or user.roles? :admin
      can :read, ScheduleRule, { business_id: user.business_id }
    end

    if user.roles? :appointment_manager or user.roles? :admin
    end

    if user.roles? :appointment_viewer or user.roles? :admin
    end

    # Users can all read their own Business
    can :read, Business, { id: user.business_id }

  end
end
