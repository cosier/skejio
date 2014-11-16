# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  business_id            :integer
#  email                  :string(255)      default(""), not null
#  encrypted_password     :string(255)      default(""), not null
#  first_name             :string(255)
#  last_name              :string(255)
#  roles                  :integer
#  status                 :integer
#  reset_password_token   :string(255)
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :inet
#  last_sign_in_ip        :inet
#  failed_attempts        :integer          default(0), not null
#  unlock_token           :string(255)
#  locked_at              :datetime
#  created_at             :datetime
#  updated_at             :datetime
#  phone                  :string(255)
#

FactoryGirl.define do

  factory :user, class: 'User' do
    association :business

    first_name Faker::Name.first_name
    last_name Faker::Name.last_name

    # override this in your builder
    email "person#{Random.rand(100.999)}@example.com"
    password '12345678'

    phone "+1 (#{Random.rand(100..999)}) #{Random.rand(100..999)}-#{Random.rand(1000..9999)}"

    factory :service_provider do
      roles [:service_provider]
    end

    factory :admin do
      roles [:admin]
    end

    factory :super_admin do
      roles [:super_admin]
    end

  end


end
