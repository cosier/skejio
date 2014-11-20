class SettingsController < BusinessesController

  load_and_authorize_resource
  skip_load_resource only: [:create]

  sidebar  :settings

  def service_selection
  end

  def user_selection
  end

  def user_priority
  end

  private

  def get_setting(key, default_value)
    Setting.get_or_create(key, business_id: @business.id, value: default_value)
  end

  def setting_params
    params[:setting].permit!
  end
end
