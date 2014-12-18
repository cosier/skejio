class RemoveServicePriority < ActiveRecord::Migration
  def change
    remove_column :services, :priority
  end
end
