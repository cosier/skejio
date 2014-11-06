class ManageController < SecureController

  before_filter :ensure_super_powers!
  layout 'super_console'

  def dashboard
    @current_sidebar = :dashboard
  end

  private

  def ensure_super_powers!
    unless current_user.roles? :super_admin
      sign_out current_user
      binding.pry
      redirect_to root_path,
        alert: "Sorry you do not have the required privileges for that area."
    end
  end
end
