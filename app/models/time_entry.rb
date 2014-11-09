# == Schema Information
#
# Table name: time_entries
#
#  id              :integer          not null, primary key
#  business_id     :integer          not null
#  office_id       :integer          not null
#  rule_service_id :integer          not null
#  day             :integer          not null
#  start_hour      :integer          not null
#  start_minute    :integer          not null
#  end_hour        :integer          not null
#  end_minute      :integer          not null
#  is_enabled      :boolean          default(TRUE)
#  valid_from_at   :datetime         not null
#  valid_until_at  :datetime         not null
#  created_at      :datetime
#  updated_at      :datetime
#

class TimeEntry < ActiveRecord::Base
  belongs_to :business
  belongs_to :office
  belongs_to :rule_service

  bitmask :day, :as => [
    :sunday,
    :monday,
    :tuesday,
    :wednesday,
    :thursday,
    :friday,
    :saturday,
  ]
end
