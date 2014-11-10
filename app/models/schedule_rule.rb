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

  belongs_to :service_provider,
    class_name: 'User',
    foreign_key: 'service_provider_id'

  has_many :rule_services
  has_many :time_entries,
    :through => :rule_services


  attr_accessor :services

end
