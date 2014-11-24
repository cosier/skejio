class SystemLogsController < ManageController
  load_and_authorize_resource
  before_filter :set_current_sidebar

  def index
    respond_with(@business, @system_logs)
  end

  def show
  end

  private

  def set_current_sidebar
    @current_sidebar = :system_logs
  end

end
