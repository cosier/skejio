# == Schema Information
#
# Table name: offices
#
#  id                 :integer          not null, primary key
#  business_id        :integer          not null
#  name               :string(255)
#  location           :string(255)
#  created_at         :datetime
#  updated_at         :datetime
#  is_schedule_public :boolean          default(TRUE)
#  time_zone          :string(255)
#  sort_order         :integer
#

FactoryGirl.define do

  factory :office, class: 'Office' do
    name Faker::Address.state
    location Faker::Address.street_name
    time_zone "Eastern Time (US & Canada)"
    is_schedule_public true
  end

end
