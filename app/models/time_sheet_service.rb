# == Schema Information
#
# Table name: time_sheet_services
#
#  id            :integer          not null, primary key
#  business_id   :integer
#  service_id    :integer
#  time_sheet_id :integer
#  created_at    :datetime
#  updated_at    :datetime
#

class TimeSheetService < ActiveRecord::Base
  belongs_to :service
  belongs_to :time_sheet
  belongs_to :business

  validates_presence_of :business
  validates_presence_of :time_sheet
  validates_presence_of :service
end
