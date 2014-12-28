# == Schema Information
#
# Table name: scheduler_sessions
#
#  id          :integer          not null, primary key
#  business_id :integer
#  customer_id :integer
#  created_at  :datetime
#  updated_at  :datetime
#  meta        :text
#  device_type :integer
#  is_finished :boolean          default(FALSE)
#  uuid        :string(255)
#

FactoryGirl.define do

  factory :scheduler_session, class: 'SchedulerSession' do
    business
    customer
  end

end
