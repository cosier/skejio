class CreateSessions < ActiveRecord::Migration
  def change
    create_table :sessions do |t|
      t.integer :business_id
      t.integer :customer_id
      t.timestamps
    end
  end
end
