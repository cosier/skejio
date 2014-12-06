class AddingMetastoreToAppointmentSelectionState < ActiveRecord::Migration
  def change
    add_column :appointment_selection_states, :meta, :text
  end
end
