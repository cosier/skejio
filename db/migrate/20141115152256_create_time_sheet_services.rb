class CreateTimeSheetServices < ActiveRecord::Migration
  def change
    create_table :time_sheet_services do |t|
      t.integer :business_id
      t.integer :service_id
      t.integer :time_sheet_id

      t.timestamps
    end
  end
end
