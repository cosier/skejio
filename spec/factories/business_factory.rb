# == Schema Information
#
# Table name: businesses
#
#  id              :integer          not null, primary key
#  name            :string(255)      not null
#  slug            :string(255)      not null
#  description     :text
#  billing_name    :string(255)
#  billing_phone   :string(255)
#  billing_email   :string(255)
#  billing_address :text
#  is_listed       :boolean          default(TRUE)
#  is_active       :boolean          default(TRUE)
#  created_at      :datetime
#  updated_at      :datetime
#

FactoryGirl.define do

  factory :business, class: 'Business' do
    name Faker::Company.name

    after(:create) do |business|
      business.sub_accounts << FactoryGirl.create(:sub_account)
    end
  end

end
