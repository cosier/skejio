# == Schema Information
#
# Table name: break_shifts
#
#  id               :integer          not null, primary key
#  business_id      :integer          not null
#  office_id        :integer
#  schedule_rule_id :integer          not null
#  day              :integer          not null
#  start_hour       :integer          not null
#  start_minute     :integer          not null
#  end_hour         :integer          not null
#  end_minute       :integer          not null
#  is_enabled       :boolean          default(TRUE)
#  valid_from_at    :datetime
#  valid_until_at   :datetime
#  created_at       :datetime
#  updated_at       :datetime
#

class BreakShift < ActiveRecord::Base
  belongs_to :schedule_rule
  belongs_to :office
  belongs_to :business

  has_many :break_services
  has_many :break_offices

  bitmask :day, :as => [
    :sunday,
    :monday,
    :tuesday,
    :wednesday,
    :thursday,
    :friday,
    :saturday,
  ]

  validates_presence_of :start_hour
  validates_presence_of :start_minute
  validates_presence_of :end_hour
  validates_presence_of :end_minute
  validates_presence_of :schedule_rule
  validates_presence_of :business

  def day_title
    day.first.to_s.titleize if day.length > 0
  end


end
