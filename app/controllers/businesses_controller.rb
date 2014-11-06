class BusinessesController < SecureController

  before_action :authenticate_user!
  load_and_authorize_resource

  before_action :validate_business_permissions


  layout 'business_console'

  include BusinessHelper

  def dashboard
    @current_sidebar = :dashboard
  end

  def pending
    @current_sidebar = :pending
    redirect_to business_path(@business) if @business.is_active?
  end

  private

  def validate_business_permissions

    # Check for invalid businesses
    return redirect_to root_path, alert: "Business not found" if @business.nil?

    # Check for permission of the current_user logged in against the business
    unless @business.valid_staff? current_user
      return redirect_to root_path, alert: "You are not authorized for that Business"
    end

    # Check that the business has been approved (is_active)
    if not @business.is_active? and params[:action] != "pending"
      return redirect_to business_pending_path(@business)
    end

  end

end
