class AddingSupportRelationToSettingKeys < ActiveRecord::Migration
  def change
    add_column :settings, :supportable_id, :integer
    add_column :settings, :supportable_type, :string
  end
end
