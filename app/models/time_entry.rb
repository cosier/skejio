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
#

class TimeEntry < ActiveRecord::Base
  belongs_to :business
  belongs_to :office
  belongs_to :time_sheet

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
    (end_hour - start_hour) + (end_minute - start_minute)
  end

end
