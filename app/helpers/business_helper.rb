module BusinessHelper

  def business_slug_path(business)
    business_dashboard_path(slug: business.slug) if business
  end

  def business_sidebar_active(link)
    current = @current_sidebar and @current_sidebar.to_sym
    if link == current
      'active'
    end
  end

  def business_user_roles
    User::ROLES.select do |role|
      not role.to_s.include? "super_"
    end.map do |role|
      [role.to_s.titleize, role]
    end
  end

  def business_sidebar_url(link)
    default_path = business_path(@business)

    return default_path unless @business.is_active?

    case link

    when :users
      business_users_path(@business)

    when :services
      business_services_path(@business)

    when :numbers
      business_numbers_path(@business)

    when :offices
      business_offices_path(@business)

    when :schedule_rules
      business_schedule_rules_path(@business)

    else
      default_path
    end
  end

end
