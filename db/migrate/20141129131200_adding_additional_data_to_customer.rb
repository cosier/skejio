class AddingAdditionalDataToCustomer < ActiveRecord::Migration
  def change
    add_column :customers, :recording_name_url, :string
  end
end
