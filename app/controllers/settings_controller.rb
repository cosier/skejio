class SettingsController < BusinessesController

  load_and_authorize_resource
  skip_load_resource only: [:create]

  before_filter :set_current_sidebar
  before_filter :load_settings, only: [:index, :show]

  def index
    @services = Service.business(@business)
    
    # Set the default visual radio input to ask, 
    # when we will be skipping service selection (< 2)
    if @services.length < 2
      @service_selection.value = Setting::SERVICE_SELECTION_ASK
    end

    if @service_providers.length < 2
      @user_priority.value = Setting::USER_PRIORITY_RANDOM
    end

  end

  def update
    @setting.update! setting_params
    hash = "##{params[:hash] || "service-selection"}"

    if @setting.errors.empty?
      flash[:success] = "#{hash.gsub('#','').titleize} Settings have been saved successfully"
    end
    respond_with @business, @setting, location: business_settings_path(@business) << hash
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

  def load_settings
    @service_selection = Setting.get_or_create Setting::SERVICE_SELECTION, 
      business_id: @business.id, 
      default_value: Setting::SERVICE_SELECTION_ASK
  
    @user_selection = Setting.get_or_create Setting::USER_SELECTION, 
      business_id: @business.id, 
      default_value: Setting::USER_SELECTION_FULL_CONTROL
  
    @user_priority = Setting.get_or_create Setting::USER_PRIORITY, 
      business_id: @business.id, 
      default_value: Setting::USER_PRIORITY_RANDOM
    
    @service_providers = User.business(@business).service_providers
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
