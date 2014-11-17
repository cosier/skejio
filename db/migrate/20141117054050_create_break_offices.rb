class CreateBreakOffices < ActiveRecord::Migration
  def change
    create_table :break_offices do |t|
      t.integer :break_shift_id
      t.integer :office_id
      t.integer :business_id

      t.timestamps
    end
  end
end
