class AddEndpointsToNumber < ActiveRecord::Migration
  def change
    add_column :numbers, :sms_url, :string
    add_column :numbers, :voice_url, :string
  end
end
