# == Schema Information
#
# Table name: time_sheets
#
#  id               :integer          not null, primary key
#  business_id      :integer          not null
#  schedule_rule_id :integer          not null
#  created_at       :datetime
#  updated_at       :datetime
#  valid_from_at    :datetime
#  valid_until_at   :datetime
#

# TimeSheet collection of TimeEntry(s)
class TimeSheet < ActiveRecord::Base
  belongs_to :schedule_rule
  belongs_to :business

  has_many :time_sheet_services,
           dependent: :destroy

  has_many :time_entries,
           dependent: :destroy

  has_many :services,
           through: :time_sheet_services

  def entry_hours
    time_entries.map(&:hours).sum
  end

  def as_json(opts = {})
    opts.reverse_merge! id: id,
                        business_id: business_id,
                        created_at: created_at,
                        updated_at: updated_at,
                        schedule_rule_id: schedule_rule_id,
                        valid_from_at: valid_from_at,
                        valid_until_at: valid_until_at,
                        services: services.map(&:id)
  end
end
