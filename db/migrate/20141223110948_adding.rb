class Adding < ActiveRecord::Migration
  def change
    add_column :appointments, :service_id, :integer, null: false
  end
end
