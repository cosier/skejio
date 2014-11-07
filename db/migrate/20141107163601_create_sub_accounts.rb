class CreateSubAccounts < ActiveRecord::Migration
  def change
    create_table :sub_accounts do |t|
      t.integer :business_id
      t.string  :auth_token
      t.string  :sid
      t.timestamps
    end
  end
end
