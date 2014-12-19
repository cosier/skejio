class AddingSessionActivityState < ActiveRecord::Migration
  def change
    add_column :scheduler_sessions, :is_finished, :boolean, default: false
    add_column :appointment_selection_states, :is_finished, :boolean, default: false
  end
end
