class ScopingSessionAsSchedulerSession < ActiveRecord::Migration
  def change
    rename_table :sessions, :scheduler_sessions
    rename_table :session_transitions, :scheduler_session_transitions
  end
end
