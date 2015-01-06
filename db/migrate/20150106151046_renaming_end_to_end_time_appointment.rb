class RenamingEndToEndTimeAppointment < ActiveRecord::Migration
  def change
    rename_column :appointments, :start, :start_time
    rename_column :appointments, :end, :end_time
  end
end
