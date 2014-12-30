# == Schema Information
#
# Table name: time_blocks
#
#  id            :integer          not null, primary key
#  time_entry_id :integer
#  business_id   :integer
#  time_sheet_id :integer
#  office_id     :integer
#  provider_id   :integer
#  day           :integer
#  created_at    :datetime
#  updated_at    :datetime
#  start_time    :datetime
#  end_time      :datetime
#

# TimeBlock is a subset of a TimeEntry.
class TimeBlock < ActiveRecord::Base

  attr_accessor :session

  belongs_to :business
  belongs_to :office
  belongs_to :time_sheet
  belongs_to :time_entry

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

  validates_presence_of :start_time
  validates_presence_of :end_time

  # Returns a collection of all detected Collisions,
  # by all individual detectors.
  def collisions
    collider.detect(self)
  end

  # Determines if this TimeBlock is collision free.
  # (Runs :all collision detectors)
  def collision_free?
    collisions.empty?
  end

  def service_provider
    time_entry.provider
  end

  # Get an identical TimeBlock, but with the time ranges
  # push a certain amount of blocks forward.
  def next(count = 1)
    dupe = self.dup
    dupe.assign_attributes start_time: start_time + push(count), end_time: end_time + push(count)
    dupe
  end

  # Get an identical TimeBlock, but with the time ranges
  # push a certain amount of blocks backward.
  def previous(count = 1)
    dupe = self.dup
    dupe.assign_attributes start_time: start_time + push(count), end_time: end_time + push(count)
    dupe
  end

  def start_time
    Skej::NLP.parse(time_entry, attributes["start_time"].to_datetime)
  end

  def end_time
    Skej::NLP.parse(time_entry, attributes["end_time"].to_datetime)
  end

  def has_appointment?
    collider.detect(self, :appointment_detector)
  end

  private

  # Determine an amount of minutes in order to push
  # the current time ranges (n) amount of blocks either forward or backward.
  def push(count)
    (count.to_i * time_entry.service.duration.to_i).minutes
  end

  # Mini Collider (memoized) factory
  def collider
    @collider ||= Skej::Appointments::Collider.new(session)
  end

end
