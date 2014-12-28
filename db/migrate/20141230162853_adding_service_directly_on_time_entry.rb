class AddingServiceDirectlyOnTimeEntry < ActiveRecord::Migration
  def change
    add_column :time_entries, :service_id, :integer
    add_column :break_shifts, :service_id, :integer
  end
end
