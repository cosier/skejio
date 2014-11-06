class CreateBusinessOffices < ActiveRecord::Migration
  def change
    create_table :business_offices do |t|
      t.integer :business_id, null: false
      t.string :name
      t.string :location
      t.timestamps
    end
  end
end
