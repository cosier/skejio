class DevController < ApplicationController
  def clear
    SystemLog.destroy_all
    SchedulerSession.destroy_all
    AppointmentSelectionState.destroy_all
    Customer.destroy_all

    render text: "Everything Cleared"

  end
end
