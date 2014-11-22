class AddAdditionalMetaDataToNumber < ActiveRecord::Migration
  def change
    add_column :numbers, :status_url, :string
    add_column :numbers, :voice_fallback_url, :string
    add_column :numbers, :sms_fallback_url, :string
    add_column :numbers, :friendly_name, :string
    add_column :numbers, :capabilities, :integer
    add_column :numbers, :account_sid, :string
    add_column :numbers, :voice_method, :string
    add_column :numbers, :sms_method, :string

    rename_column :numbers, :number, :phone_number
    change_column :numbers, :phone_number, :string, null: false

  end
end
