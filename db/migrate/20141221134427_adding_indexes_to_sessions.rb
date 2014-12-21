class AddingIndexesToSessions < ActiveRecord::Migration
  def change
    add_index :scheduler_sessions, :uuid
    add_index :appointment_selection_states, :uuid
  end
end
