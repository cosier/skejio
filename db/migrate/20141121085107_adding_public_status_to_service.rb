class AddingPublicStatusToService < ActiveRecord::Migration
  def change
    add_column :services, :is_public, :boolean, :default => true
  end
end
