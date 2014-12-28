# == Schema Information
#
# Table name: customers
#
#  id                 :integer          not null, primary key
#  phone_number       :string(255)
#  first_name         :string(255)
#  last_name          :string(255)
#  sms_verified       :boolean          default(FALSE)
#  voice_verified     :boolean          default(FALSE)
#  verification_code  :string(255)
#  created_at         :datetime
#  updated_at         :datetime
#  recording_name_url :string(255)
#  email              :string(255)
#

FactoryGirl.define do

  factory :customer, class: 'Customer' do
    first_name Faker::Name.first_name
    last_name Faker::Name.last_name

    # override this in your builder
    sequence(:email) { |n| "customer#{n}@example.com" }

    phone_number "+1#{Random.rand(100..999)}#{Random.rand(100..999)}#{Random.rand(1000..9999)}"

  end


end
