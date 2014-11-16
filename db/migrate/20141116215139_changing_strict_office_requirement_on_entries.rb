class ChangingStrictOfficeRequirementOnEntries < ActiveRecord::Migration
  def change
    change_column :break_shifts, :office_id, :integer, null: true
    change_column :time_entries, :office_id, :integer, null: true
  end
end
