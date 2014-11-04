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

  def business_sidebar_url(link)
    default_path = business_slug_path(@business)

    return default_path unless @business.is_active?

    case link
    when :pass
    else
      default_path
    end
  end

end
