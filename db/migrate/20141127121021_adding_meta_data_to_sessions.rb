class AddingMetaDataToSessions < ActiveRecord::Migration
  def change
    add_column :scheduler_sessions, :meta, :text
    add_column :scheduler_sessions, :type, :integer
  end
end
