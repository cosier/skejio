# == Schema Information
#
# Table name: schedule_rules
#
#  id                  :integer          not null, primary key
#  service_provider_id :integer          not null
#  business_id         :integer          not null
#  is_active           :boolean          default(TRUE)
#  created_at          :datetime
#  updated_at          :datetime
#

class ScheduleRule < ActiveRecord::Base
  belongs_to :user # service_provider
  has_many :rule_services
  has_many :time_entries,
    :through => :rule_services
end
