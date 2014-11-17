class CreateBreakServices < ActiveRecord::Migration
  def change
    create_table :break_services do |t|
      t.integer :break_shift_id
      t.integer :service_id
      t.integer :business_id

      t.timestamps
    end
  end
end
