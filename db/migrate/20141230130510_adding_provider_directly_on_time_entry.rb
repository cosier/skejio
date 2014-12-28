class AddingProviderDirectlyOnTimeEntry < ActiveRecord::Migration
  def change
    add_column :time_entries, :provider_id, :integer
    add_column :break_shifts, :provider_id, :integer
  end
end
