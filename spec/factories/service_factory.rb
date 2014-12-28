# == Schema Information
#
# Table name: services
#
#  id          :integer          not null, primary key
#  business_id :integer          not null
#  name        :string(255)      not null
#  description :text
#  duration    :integer          default(60)
#  created_at  :datetime
#  updated_at  :datetime
#  is_public   :boolean          default(TRUE)
#  sort_order  :integer
#

FactoryGirl.define do

  factory :service, class: 'Service' do
    name Faker::Commerce.department
    description Faker::Company.catch_phrase
    duration 60
  end

end
