class AddingIndexForOfficeAndFriends < ActiveRecord::Migration
  def change
    add_index :offices, [:business_id, :id], name: :business_office
    add_index :services, [:business_id, :id], name: :business_service
    add_index :users, [:business_id, :id], name: :business_user
    add_index :settings, [:business_id, :id], name: :business_setting
  end
end
