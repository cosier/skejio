class ApplicationController < ActionController::Base
  respond_to :html, :xml, :json

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def after_sign_in_path_for(resource)
    session[:previous_url] || root_path
  end

end
