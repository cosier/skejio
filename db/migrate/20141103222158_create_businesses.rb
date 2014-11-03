class CreateBusinesses < ActiveRecord::Migration
  def change
    create_table :businesses do |t|
      t.string :name, null: false
      t.string :slug, null: false
      t.text   :description

      t.string :billing_name
      t.string :billing_phone
      t.string :billing_email
      t.text   :billing_address

      t.boolean :is_listed, default: true
      t.boolean :is_active, default: true

      t.timestamps
    end
  end
end
