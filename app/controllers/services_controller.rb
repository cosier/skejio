class ServicesController < BusinessesController

  load_and_authorize_resource :service, parent: false, except: [:create]
  skip_load_resource only: [:create]

  before_filter :set_current_sidebar

  def index
    respond_with(@services)
  end

  def show
    respond_with(@service)
  end

  def new
    respond_with(@service)
  end

  def edit
  end

  def create
    authorize! :create, Service

    @service = Service.new(service_params)
    @service.save
    respond_with(@business, @service)
  end

  def update
    @service.update(service_params)
    respond_with(@business, @service)
  end

  def destroy
    @service.destroy
    respond_with(@business, @service)
  end

  private

  def service_params
    params.require(:service).permit(:business_id, :name, :description, :priority, :duration)
  end

  def set_current_sidebar
    @current_sidebar = :services
  end

end
