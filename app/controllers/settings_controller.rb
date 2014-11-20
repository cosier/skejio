class SettingsController < BusinessesController

  load_and_authorize_resource
  skip_load_resource only: [:create]

  before_filter :set_current_sidebar

  def service_selection
  end

  def user_selection
  end

  def user_priority
  end

  private

  def set_current_sidebar
    @current_sidebar = :settings
  end

  def get_setting(key, default_value)
    Setting.get_or_create(key, business_id: @business.id, value: default_value)
  end

  def setting_params
    params[:setting].permit!
  end
end
