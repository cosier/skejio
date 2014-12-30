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
#  floating_break   :integer          default(0)
#  provider_id      :integer
#  service_id       :integer
#

class BreakShift < ActiveRecord::Base
  belongs_to :schedule_rule
  belongs_to :office
  belongs_to :business

  has_many :break_services,
    :dependent => :destroy

  has_many :break_offices,
    :dependent => :destroy

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

  class << self
    def started_between(start_time, end_time, chain = self)
      chain.where start_hour: start_time.hour..end_time.hour,
                  start_minute: start_time.strftime('%M')..end_time.strftime('%M')
    end

    def ending_between(start_time, end_time, chain = self)
      chain.where end_hour: start_time.hour..end_time.hour,
                  end_minute: start_time.strftime('%M')..end_time.strftime('%M')
    end
  end

  def day_title
    day.first.to_s.titleize if day.length > 0
  end

  def hours
    (end_hour - start_hour) + (end_minute - start_minute)
  end


end
