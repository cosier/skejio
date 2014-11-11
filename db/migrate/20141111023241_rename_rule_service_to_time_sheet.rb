class RenameRuleServiceToTimeSheet < ActiveRecord::Migration
  def change
    rename_table :rule_services, :time_sheets
    remove_column :time_sheets, :service_id
    rename_column :time_entries, :rule_service_id, :time_sheet_id
  end
end
