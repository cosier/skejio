class ManageController < SecureController

  before_filter :authenticate_user!
  before_filter :ensure_super_powers!
  layout 'super_console'

  skip_load_resource

  def dashboard
    @current_sidebar = :dashboard
  end

  def show_twilio_account
    @current_sidebar = :dashboard
    @account = Skej::Twilio.sub_account(params[:sid])
  end

  def show_test_client
    @numbers = Number.all
    @current_sidebar = :simulator

    @twilio_token = create_twilio_capability
  end

  def show_twilio_stats
    @current_sidebar = :twilio_stats
    @sub_accounts = Skej::Twilio.sub_accounts status: 'active'
  end

  private

  def create_twilio_capability
    Rails.cache.fetch "twilio_capability_for_#{current_user.id}_v1", :expires_in => 1.hour do
      app_sid = Skej::Twilio.application.sid
      capability = Skej::Twilio.create_capability
      capability.allow_client_outgoing app_sid
      capability.allow_client_incoming "simulator-#{current_user}"
      capability.generate
    end
  end

  def ensure_super_powers!
    unless current_user.roles? :super_admin
      redirect_to root_path,
        alert: "Sorry you do not have the required privileges for that area."
    end
  end
end
