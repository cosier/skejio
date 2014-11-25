class ManageController < SecureController

  before_filter :authenticate_user!
  before_filter :ensure_super_powers!
  layout 'super_console'

  skip_load_resource

  def dashboard
    @sub_accounts = Skej::Twilio.sub_accounts status: 'active'
    @current_sidebar = :dashboard
  end

  def show_twilio_account
    @account = Skej::Twilio.sub_account(params[:sid])
  end

  private

  def ensure_super_powers!
    unless current_user.roles? :super_admin
      redirect_to root_path,
        alert: "Sorry you do not have the required privileges for that area."
    end
  end
end
