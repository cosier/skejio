class AddingAdditionalSortOrders < ActiveRecord::Migration
  def change
    add_column :services, :sort_order, :integer
    add_column :offices, :sort_order, :integer
  end
end
