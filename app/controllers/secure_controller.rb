class SecureController < ApplicationController
  before_filter :authenticate_user!

  # Enforce CanCan permissions
  load_and_authorize_resource
  skip_load_resource :only => :dashboard

  rescue_from CanCan::AccessDenied do |exception|
    path = root_path

    if current_user and current_user.roles? :super_admin
      path = manage_dashboard_path

    elsif current_user
      path = business_dashboard_path(slug: current_user.business.slug)
    end

    redirect_to path, :alert => exception.message
  end

end
