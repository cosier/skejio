class SettingsController < BusinessesController

  load_and_authorize_resource
  skip_load_resource only: [:create]

  sidebar  :settings

  def index
    respond_with(@settings)
  end

  def show
    respond_with(@setting)
  end

  def new
    respond_with(@setting)
  end

  def edit
  end

  def create
    authorize! :create, Setting

    @setting = User.new(user_params)
    @setting.save
    respond_with(@business, @setting)
  end

  def update
    setting_data = setting_params.dup

    @setting.update(setting_data)
    respond_with(@business, @setting)
  end

  def destroy
    @setting.destroy
    respond_with(@business, @setting)
  end

  private

  def setting_params
    params[:setting].permit!
  end
end
