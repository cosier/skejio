class CreateAppointmentSelectionTransitions < ActiveRecord::Migration
  def change
    create_table :appointment_selection_transitions do |t|
      t.string :to_state, null: false
      t.text :metadata, default: "{}"
      t.integer :sort_key, null: false
      t.integer :appointment_selection_state_id, null: false
      t.timestamps
    end

    add_index :appointment_selection_transitions, :appointment_selection_state_id, name: 'unique_transition_appointments'
    add_index :appointment_selection_transitions, [:sort_key, :appointment_selection_state_id], unique: true, name: 'unique_transition_appointments_sorted'
  end
end
