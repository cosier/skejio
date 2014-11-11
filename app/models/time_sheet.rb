# == Schema Information
#
# Table name: time_sheets
#
#  id               :integer          not null, primary key
#  business_id      :integer          not null
#  schedule_rule_id :integer          not null
#  created_at       :datetime
#  updated_at       :datetime
#

class TimeSheet < ActiveRecord::Base
  belongs_to :schedule_rule

  has_many :time_sheet_services
  has_many :time_entries
end
