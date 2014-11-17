# == Schema Information
#
# Table name: break_offices
#
#  id             :integer          not null, primary key
#  break_shift_id :integer
#  office_id      :integer
#  business_id    :integer
#  created_at     :datetime
#  updated_at     :datetime
#

class BreakOffice < ActiveRecord::Base
  belongs_to :office
  belongs_to :business
  belongs_to :break_shift
end
