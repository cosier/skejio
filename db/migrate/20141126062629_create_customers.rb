class CreateCustomers < ActiveRecord::Migration
  def change
    create_table :customers do |t|
      t.string :phone_number
      t.string :first_name
      t.string :last_name
      t.boolean :sms_verified, default: false
      t.boolean :voice_verified, default: false
      t.string :verification_code
      t.timestamps
    end
  end
end
