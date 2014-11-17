class AddingValidityDatesToTimeSheets < ActiveRecord::Migration
  def change
    add_column :time_sheets, :valid_from_at, :datetime
    add_column :time_sheets, :valid_until_at, :datetime
  end
end
