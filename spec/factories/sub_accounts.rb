# == Schema Information
#
# Table name: sub_accounts
#
#  id            :integer          not null, primary key
#  business_id   :integer
#  friendly_name :string(255)
#  auth_token    :string(255)
#  sid           :string(255)
#  created_at    :datetime
#  updated_at    :datetime
#

FactoryGirl.define do
  factory :sub_account do
    friendly_name "super-friendly-business"
    sid "AC4cfc5ec9de5735209d9660cf72fcdcfa"
    auth_token "1010"
  end

end
