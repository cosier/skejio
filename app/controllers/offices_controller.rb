class OfficesController < SecureController
  before_action :set_business_office, only: [:show, :edit, :update, :destroy]
  before_action :set_current_sidebar

  before_action :preload_business_office, only: [:create]

  load_and_authorize_resource :business
  load_and_authorize_resource :office, parent: false

  skip_load_resource :only => :create

  layout 'business_console'

  def index
    respond_with(@offices)
  end

  def show
    respond_with(@office)
  end

  def new
    respond_with(@office)
  end

  def edit
  end

  def create
    @office.save

    if @office.persisted?
      respond_with(@office, location: business_office_path(@business, @office))
    else
      respond_with(@office)
    end
  end

  def update
    @office.update(office_params)
    respond_with(@office, location: business_office_path(@business, @office))
  end

  def destroy
    @office.destroy
    respond_with(@office, location: business_offices_path(@business))
  end

  private

    def preload_business_office
      @office = Office.new(office_params)
    end

    def set_current_sidebar
      @current_sidebar = :offices
    end

    def set_business_office
      @office = Office.find(params[:id])
    end

    def office_params
      p = params.require(:office).permit(:name, :location).dup
      p[:business_id] = params[:business_id]
      p
    end
end
