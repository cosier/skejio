# == Schema Information
#
# Table name: appointments
#
#  id                    :integer          not null, primary key
#  business_id           :integer          not null
#  service_provider_id   :integer          not null
#  office_id             :integer          not null
#  customer_id           :integer          not null
#  created_by_session_id :integer          not null
#  start                 :datetime
#  end                   :datetime
#  organizer             :text
#  description           :text
#  summary               :text
#  attendees             :text
#  location              :text
#  status                :integer
#  notes                 :text
#  is_confirmed          :boolean          default(FALSE)
#  is_active             :boolean          default(TRUE)
#  created_at            :datetime
#  updated_at            :datetime
#

class Appointment < ActiveRecord::Base

  # Returns a short one-liner of the Appointment details
  def label

  end

  # Returns a quick/n/short summary of the Appointment details
  def summary
    # TODO
  end

end
