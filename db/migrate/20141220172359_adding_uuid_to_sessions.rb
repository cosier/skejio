class AddingUuidToSessions < ActiveRecord::Migration
  def change
    add_column :scheduler_sessions, :uuid, :string
    add_column :appointment_selection_states, :uuid, :string
  end
end
