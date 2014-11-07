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

    first_name 'John'
    last_name 'Doe'

    # override this in your builder
    email "john.doe.#{Random.rand(9999)}@example.com"
    password '12345678'
    phone '+1 (555) 555-5555'
  end


end
