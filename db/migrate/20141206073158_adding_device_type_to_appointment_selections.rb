class AddingDeviceTypeToAppointmentSelections < ActiveRecord::Migration
  def change
    add_column :appointment_selection_states, :device_type, :integer
  end
end
