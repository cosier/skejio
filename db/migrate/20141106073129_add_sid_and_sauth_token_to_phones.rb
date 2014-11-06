class AddSidAndSauthTokenToPhones < ActiveRecord::Migration
  def change
    add_column :phones, :sid, :string
    add_column :phones, :sauth_token, :string
  end
end
