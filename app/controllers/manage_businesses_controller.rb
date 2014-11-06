class ManageBusinessesController < ManageController
  respond_to :html, :xml, :js

  before_action :set_current_navigation

  layout 'super_console'

  def index
    @manage_businesses = ManageBusiness.all
    respond_with(@manage_businesses)
  end

  def show
    respond_with(@manage_business)
  end

  def new
    @manage_business = ManageBusiness.new
    respond_with(@manage_business)
  end

  def edit
  end

  def create
    @manage_business = ManageBusiness.new(business_params)
    @manage_business.save
    respond_with(@manage_business)
  end

  def update
    @manage_business.update(business_params.permit!)
    respond_with(@manage_business)
  end

  def destroy
    @manage_business.destroy
    respond_with(@manage_business)
  end

  private
    # def set_business
    #   @business = ManageBusiness.find(params[:id])
    # end

    def set_current_navigation
      @current_sidebar = :businesses
    end

    def business_params
      params[:manage_business]
    end
end
