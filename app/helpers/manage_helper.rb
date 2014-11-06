module ManageHelper

  def manage_sidebar_active(link)
    current = @current_sidebar and @current_sidebar.to_sym
    if link == current
      'active'
    end
  end
end
