class BusinessesController < SecureController

  before_action :authenticate_user!

  # before_action :get_business
  before_action :validate_business_permissions

  load_and_authorize_resource :business

  layout 'business_console'

  include BusinessHelper

  def dashboard
    @current_sidebar = :dashboard
  end

  def pending
    @current_sidebar = :pending
    redirect_to business_slug_path(@business) if @business.is_active?
  end

  private

  def get_business
    @business = Business.where(slug: params[:slug]).first if params[:slug]
  end

  def validate_business_permissions

    # Check for invalid businesses
    return redirect_to "/", alert: "Business not found" if @business.nil?

    # Check for permission of the current_user logged in against the business
    unless @business.valid_staff? current_user
      return redirect_to "/", alert: "You are not authorized for that Business"
    end

    # Check that the business has been approved (is_active)
    if not @business.is_active? and params[:action] != "pending"
      return redirect_to business_pending_path(slug: @business.slug)
    end

  end

end
