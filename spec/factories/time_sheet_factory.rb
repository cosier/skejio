# == Schema Information
#
# Table name: time_sheets
#
#  id               :integer          not null, primary key
#  business_id      :integer          not null
#  schedule_rule_id :integer          not null
#  created_at       :datetime
#  updated_at       :datetime
#  valid_from_at    :datetime
#  valid_until_at   :datetime
#

FactoryGirl.define do
  factory :time_sheet do
    business
    schedule_rule
  end
end
