class UpdatingForeignKeySchedulerSession < ActiveRecord::Migration
  def change
    rename_column :scheduler_session_transitions, :session_id, :scheduler_session_id
  end
end
