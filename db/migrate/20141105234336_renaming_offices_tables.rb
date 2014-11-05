class RenamingOfficesTables < ActiveRecord::Migration
  def change
    rename_table :business_offices, :offices
  end
end
