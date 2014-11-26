class SystemLogsController < ManageController
  load_and_authorize_resource
  before_filter :set_current_sidebar

  def index
    @system_logs = @system_logs.order(id: :desc)
    respond_with(@business, @system_logs)
  end

  def show
  end

  def clear_logs
    SystemLog.destroy_all
    redirect_to system_logs_path, notice: 'System Logs Cleared— Have a nice day!'
  end

  def clear_sessions
    Session.destroy_all
    redirect_to system_logs_path, notice: 'Customer Session(s) Cleared— Have a nice day!'
  end

  private

  def set_current_sidebar
    @current_sidebar = :system_logs
  end

end
