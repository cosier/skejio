# == Schema Information
#
# Table name: rule_services
#
#  id               :integer          not null, primary key
#  business_id      :integer          not null
#  service_id       :integer          not null
#  schedule_rule_id :integer          not null
#  created_at       :datetime
#  updated_at       :datetime
#

class RuleService < ActiveRecord::Base
  belongs_to :schedule_rule
  belongs_to :service

  has_many :time_entries
end
