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


  def collisions
    collider.detect(self)
  end

  def collision_free?
    collisions.empty?
  end

  def service_provider
    time_entry.provider
  end

  private

  def collider
    @collider ||= Skej::Appointments::Collider.new(session)
  end

end
