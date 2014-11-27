class UpdatingForeignKeySession < ActiveRecord::Migration
  def change
    remove_index :scheduler_session_transitions, column: :session_id
    remove_index :scheduler_session_transitions, column: [:sort_key, :session_id]
  end
end
