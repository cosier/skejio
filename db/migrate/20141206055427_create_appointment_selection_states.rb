class CreateAppointmentSelectionStates < ActiveRecord::Migration
  def change
    create_table :appointment_selection_states do |t|
      t.integer :scheduler_session_id, null: false
      t.integer :business_id
      t.timestamps
    end
  end
end
