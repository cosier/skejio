# == Schema Information
#
# Table name: schedule_rules
#
#  id                  :integer          not null, primary key
#  service_provider_id :integer          not null
#  business_id         :integer          not null
#  is_active           :boolean          default(TRUE)
#  created_at          :datetime
#  updated_at          :datetime
#

class ScheduleRule < ActiveRecord::Base

  belongs_to :business
  belongs_to :service_provider,
    class_name: 'User',
    foreign_key: 'service_provider_id'

  has_many :break_shifts

  has_many :time_sheets
  has_many :time_entries,
    :through => :time_sheets

  attr_accessor :services

  validates_presence_of :service_provider
  validates_presence_of :business

  def work_hours
    @work_hours_cache ||= time_sheets.map(&:entry_hours).sum
  end

  def break_hours
    @break_hours_cache ||= break_shifts.map(&:hours).sum
  end

end
