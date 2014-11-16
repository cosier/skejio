class BreakShiftRenameParentAssoc < ActiveRecord::Migration
  def change
    rename_column :break_shifts, :time_sheet_id, :schedule_rule_id
  end
end
