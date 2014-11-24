class CreateSystemLogs < ActiveRecord::Migration
  def change
    create_table :system_logs do |t|
      t.integer :parent_id
      t.integer :business_id
      t.integer :customer_id
      t.integer :session_id
      t.integer :session_tx_id
      t.integer :log_type
      t.string :from
      t.string :to
      t.text :meta
      t.timestamps
    end
  end
end
