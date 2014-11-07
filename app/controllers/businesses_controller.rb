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

end
