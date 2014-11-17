# == Schema Information
#
# Table name: break_services
#
#  id             :integer          not null, primary key
#  break_shift_id :integer
#  service_id     :integer
#  business_id    :integer
#  created_at     :datetime
#  updated_at     :datetime
#

class BreakService < ActiveRecord::Base
  belongs_to :break_shift
  belongs_to :service
  belongs_to :business
end
