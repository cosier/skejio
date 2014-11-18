class BusinessesController < SecureController

  load_and_authorize_resource :business,
    :id_param => :business_id

  before_action :validate_business
  before_action :set_current_sidebar

  layout 'business_console'
  sidebar :dashboard

  def index
    @@sidebar = :dashboard
  end

  def show
    @@sidebar = :dashboard
  end

  def pending
    @@sidebar = :pending
    redirect_to business_path(@business) if @business.is_active?
  end

end
