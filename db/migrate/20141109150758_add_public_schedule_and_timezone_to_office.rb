class AddPublicScheduleAndTimezoneToOffice < ActiveRecord::Migration
  def change
    add_column :offices, :is_schedule_public, :boolean, default: true
    add_column :offices, :time_zone, :string
  end
end
