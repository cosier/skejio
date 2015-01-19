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
    sid           "ACb8a1f1ccacd58addc8110308676f44ef"
    auth_token    "6c735d1db5601b97f4d60b1e51c60c08"

    after(:create) do |m|
      m.numbers.create!(
        phone_number:   "+1#{Random.rand(100..999)}#{Random.rand(1000..9999)}",
        sub_account_id: m.id,
        sid: "#{Random.rand(10000..99999)}")
    end

  end
end
