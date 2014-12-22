class RemovingTransitionIndexes < ActiveRecord::Migration
  def change
    remove_index :appointment_selection_transitions, name: :unique_transition_appointments
    remove_index :appointment_selection_transitions, name: :unique_transition_appointments_sorted
  end
end
