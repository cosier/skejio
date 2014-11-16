class ChangingBreakShiftNotNulls < ActiveRecord::Migration
  def change
    change_column :break_shifts, :valid_from_at,  :datetime, null: true
    change_column :break_shifts, :valid_until_at, :datetime, null: true

    change_column :time_entries, :valid_from_at,  :datetime, null: true
    change_column :time_entries, :valid_until_at, :datetime, null: true
  end
end
