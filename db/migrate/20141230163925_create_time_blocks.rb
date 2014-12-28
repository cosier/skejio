class CreateTimeBlocks < ActiveRecord::Migration
  def change
    create_table :time_blocks do |t|
      t.integer :time_entry_id
      t.integer :business_id
      t.integer :time_sheet_id
      t.integer :office_id
      t.integer :provider_id
      t.integer :day

      t.integer :start_hour
      t.integer :start_minute
      t.integer :end_hour
      t.integer :end_minute

      t.timestamps
    end
  end
end
