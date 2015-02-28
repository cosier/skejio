# == Schema Information
#
# Table name: time_entries
#
#  id             :integer          not null, primary key
#  business_id    :integer          not null
#  office_id      :integer
#  time_sheet_id  :integer          not null
#  day            :integer          not null
#  start_hour     :integer          not null
#  start_minute   :integer          not null
#  end_hour       :integer          not null
#  end_minute     :integer          not null
#  is_enabled     :boolean          default(TRUE)
#  valid_from_at  :datetime
#  valid_until_at :datetime
#  created_at     :datetime
#  updated_at     :datetime
#  provider_id    :integer
#  service_id     :integer
#

class TimeEntry < ActiveRecord::Base
  belongs_to :business
  belongs_to :office
  belongs_to :time_sheet
  belongs_to :service

  belongs_to :provider,
    class_name: 'User',
    foreign_key: 'provider_id'

  attr_accessor :session

  bitmask :day, :as => [
    :sunday,
    :monday,
    :tuesday,
    :wednesday,
    :thursday,
    :friday,
    :saturday,
  ]

  validates_presence_of :business

  validates_presence_of :start_hour
  validates_presence_of :start_minute
  validates_presence_of :end_hour
  validates_presence_of :end_minute

  def day_title
    day.first.to_s.titleize if day.length > 0
  end

  def hours
    ((((end_hour - start_hour) * 60) + (end_minute - start_minute)) / 60).floor
  end

  def duration
    (((end_hour - start_hour) * 60) + (end_minute - start_minute))
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

  def offset
    office.time_zone if office
  end

  def now
    if session.present?
      now = Skej::NLP.midnight(session)
    else
      now = DateTime.now
    end
  end

end
