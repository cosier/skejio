class ManageBusinessesController < ManageController
  before_action :set_current_navigation

  load_and_authorize_resource :business, parent: false

  layout 'super_console'

  def index
    respond_with(@businesses)
  end

  def show
    respond_with(@business)
  end

  def new
    respond_with(@business)
  end

  def edit
  end

  def create
    @business.save
    respond_with(@business, location: manage_business_path(@business))
  end

  def update
    @business.update(business_params.permit!)
    respond_with(@business, location: manage_business_path(@business))
  end

  def destroy
    @business.destroy
    respond_with(@business, location: manage_business_path(@business))
  end

  private

  # def set_business
  #   @business = ManageBusiness.find(params[:id])
  # end

  def set_current_navigation
    @current_sidebar = :businesses
  end

  def business_params
    params[:business]
  end

end
