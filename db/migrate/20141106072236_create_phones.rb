class CreatePhones < ActiveRecord::Migration
  def change
    create_table :phones do |t|
      t.string :subaccount
      t.string :number
      t.references :phonable, polymorphic: true, index: true

      t.timestamps
    end
  end
end
