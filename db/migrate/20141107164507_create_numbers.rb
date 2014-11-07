class CreateNumbers < ActiveRecord::Migration
  def change
    create_table :numbers do |t|
      t.references :sub_account, index: true
      t.references :office, index: true
      t.string :number
      t.string :sid
      t.timestamps
    end
  end
end
