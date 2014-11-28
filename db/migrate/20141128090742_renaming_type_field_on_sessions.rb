class RenamingTypeFieldOnSessions < ActiveRecord::Migration
  def change
    rename_column :scheduler_sessions, :type, :device_type
  end
end
