class CreateTimeEntries < ActiveRecord::Migration
  def change
    create_table :time_entries do |t|
      t.integer :business_id, null: false
      t.integer :office_id, null: false
      t.integer :rule_service_id, null: false
      t.integer :day, null: false
      t.integer :start_hour, null: false
      t.integer :start_minute, null: false
      t.integer :end_hour, null: false
      t.integer :end_minute, null: false

      t.boolean :is_enabled, default: true

      t.datetime :valid_from_at, null: false
      t.datetime :valid_until_at, null: false
      t.timestamps
    end
  end
end
