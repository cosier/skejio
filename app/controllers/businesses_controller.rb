class BusinessesController < SecureController

  load_and_authorize_resource :business,
    :id_param => :business_id

  before_action :validate_business

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

  def validate_business

    # Check for invalid businesses
    if @business.nil?
      binding.pry
      return redirect_to "/", alert: "Business not found"
    end

    # Check that the business has been approved (is_active)
    if not @business.is_active? and params[:action] != "pending"
      return redirect_to business_pending_path(@business)
    end
  end

end
