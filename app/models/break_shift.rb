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
  attr_accessor :session

  belongs_to :schedule_rule
  belongs_to :office
  belongs_to :business
  belongs_to :service

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

  def can_float?
    if floating_break > 0
      provider = User.find(provider_id)

      left_start_time = start_time - floating_break.minutes - 30.seconds
      left_end_time   = start_time

      right_start_time = end_time
      right_end_time   = end_time + floating_break.minutes + 30.seconds

      base  = Appointment.where(service_provider_id: provider_id)
      left, right = [],[]

      # Backwards time query for left sided appointments
      left  << base.where(start_time:  left_start_time..left_end_time).to_a
      left  << base.where(end_time:    left_start_time..left_end_time).to_a

      # Forward based time queries for right sided appointments
      right << base.where(start_time: right_start_time..right_end_time).to_a
      right << base.where(end_time:   right_start_time..right_end_time).to_a

      # Floatable if we can go either left or right
      if left.flatten.empty? or right.flatten.empty?
        return true
      else
        return false
      end

    else
      return false
    end
  end

  def day_title
    day.first.to_s.titleize if day.length > 0
  end

  def hours
    (end_hour - start_hour) + (end_minute - start_minute)
  end

  def range
    start_time..end_time
  end

  def start_time
    Skej::Warp.zone DateTime.new(
      now.year, now.month, now.day, start_hour, start_minute), offset
  end

  def end_time
    Skej::Warp.zone DateTime.new(
      now.year, now.month, now.day, end_hour, end_minute), offset
  end

  def now
    if session.present?
      now = Skej::NLP.midnight(session)
    else
      now = DateTime.now
    end
  end

  def offset
    session.chosen_office.time_zone if session
  end


end
