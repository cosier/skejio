class ServicesController < BusinessesController

  load_and_authorize_resource

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
    @service = Service.new(service_params)
    @service.save
    respond_with(@service)
  end

  def update
    @service.update(service_params)
    respond_with(@service)
  end

  def destroy
    @service.destroy
    respond_with(@service)
  end

  private

  def service_params
    params.require(:service).permit(:business, :name, :description, :priority, :duration)
  end
end
