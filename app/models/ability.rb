class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new # guest user (not logged in)

    ###########################################
    # Super Admin Rules
    can :manage, Business if user.roles? :super_business_editor
    can :read,   Business if user.roles? :super_business_viewer

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
      can :manage, Business, { id: user.business }

      # Can manage their own Offices for their associated Business
      can :manage, Office, { business: user.business }

      # Can manage Numbers belonging to the subaccount which that user has access to.
      can :manage, Number, { sub_account: user.business.sub_account }

      # Can manage Service belonging to the same business
      can :manage, Service, { business: user.business }

      # Can manage Users belonging to the same Business
      can :manage, User, { business: user.business }

      # Can manage Settings belonging to the same Business
      can :manage, Setting, { business: user.business }
    end

    if user.roles? :schedule_manager or user.roles? :admin
      can :manage, ScheduleRule, { business: user.business }
      can :manage, TimeEntry, { business: user.business }

      can :manage, TimeSheet, { business: user.business }
      can :manage, TimeSheetService, { business: user.business }

      can :manage, BreakShift, { business: user.business }
      can :manage, BreakOffice, { business: user.business }
    end

    if user.roles? :schedule_viewer or user.roles? :admin
      can :read, ScheduleRule, { business: user.business }
    end

    if user.roles? :appointment_manager or user.roles? :admin
    end

    if user.roles? :appointment_viewer or user.roles? :admin
    end

    if user.business.present?
      # Users can all read their own Business
      can :read, Business, { id: user.business.id }
      can :pending, Business, { id: user.business.id }
    end

  end
end
