class ApplicationController < ActionController::Base
  respond_to :html, :xml, :json

  rescue_from StandardError, with: :general_error_logger

  def general_error_logger(error = false)
    Rollbar.log 'error', error.message if Rails.env.production?
    logger.error error.message
    raise error
  end

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def after_sign_in_path_for(resource)
    session[:previous_url] || root_path
  end

  def self.sidebar(target)
    @@sidebar = (target and target.to_s.downcase.to_sym)
  end

  def set_current_sidebar(target = false)
    @current_sidebar ||= (target || @@sidebar)
  end

end
