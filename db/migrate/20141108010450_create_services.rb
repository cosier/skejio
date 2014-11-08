class CreateServices < ActiveRecord::Migration
  def change
    create_table :services do |t|
      t.integer :business_id, null: false
      t.string :name, null: false
      t.text   :description
      t.integer :priority, default: 1
      t.integer :duration, default: 60

      t.timestamps
    end
  end
end
