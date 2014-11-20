class CreateSettings < ActiveRecord::Migration
  def change
    create_table :settings do |t|
      t.integer :business_id, null: false
      t.string  :key,   null: false
      t.string  :value, null: false
      t.text :description
      t.boolean :is_active, default: true

      t.timestamps
    end
  end
end
