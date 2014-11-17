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
      path = business_path(current_user.business)
    end

    redirect_to path, :alert => exception.message
  end

  private

  def validate_business

    # Check for invalid businesses
    if @business.nil?
      return redirect_to "/", alert: "Business not found"
    end

    # Check that the business has been approved (is_active)
    if not @business.is_active? and params[:action] != "pending"
      return redirect_to business_pending_path(@business)
    end
  end

end
