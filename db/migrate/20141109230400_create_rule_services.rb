class CreateRuleServices < ActiveRecord::Migration
  def change
    create_table :rule_services do |t|
      t.integer :business_id, null: false
      t.integer :service_id, null: false
      t.integer :schedule_rule_id, null: false
      t.timestamps
    end
  end
end
