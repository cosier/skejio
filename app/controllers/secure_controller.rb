class SecureController < ApplicationController
  before_filter :authenticate_user!

  # Enforce CanCan permissions
  load_and_authorize_resource
  skip_load_resource :only => :dashboard

  rescue_from CanCan::AccessDenied do |exception|
    binding.pry
    redirect_to manage_dashboard_path, :alert => exception.message
  end

end
