class SettingsController < BusinessesController

  load_and_authorize_resource
  skip_load_resource only: [:create]

  before_filter :set_current_sidebar

  def index
    @services = Service.business(@business)
    @service_selection = Setting.get_or_create :service_selection, 
      business_id: @business.id, 
      default_value: :ask
    
    # Set the default visual radio input to ask, 
    # when we will be skipping service selection (< 2)
    if @services.length < 2
      @service_selection.value = 'ask'
    end

  end

  def update
    @setting.update! setting_params

    if @setting.errors.empty?
      flash[:success] = "Settings have been saved successfully"
    end

    respond_with @business, @setting, location: business_settings_path(@business)
  end

  def show
    respond_with @business, @setting do |format|
      format.html { redirect_to business_settings_path(@business) }
    end
  end


  private

  def set_current_sidebar
    @current_sidebar = :settings
  end

  def get_setting(key, default_value)
    Setting.get_or_create(key, business_id: @business.id, value: default_value)
  end

  def setting_params
    p = params.dup[:setting]
    p[:business_id] = @business.id
    p.permit!
  end
end
