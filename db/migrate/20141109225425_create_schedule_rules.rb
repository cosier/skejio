class CreateScheduleRules < ActiveRecord::Migration
  def change
    create_table :schedule_rules do |t|
      t.integer :service_provider_id, null: false
      t.integer :business_id, null: false
      t.boolean :is_active, default: true
      t.timestamps
    end
  end
end
