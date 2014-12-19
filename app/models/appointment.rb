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


  belongs_to :service_provider,
    class_name: 'User'

  belongs_to :office
  belongs_to :business
  belongs_to :customer

  belongs_to :session,
    foreign_key: 'created_by_session_id',
    class_name: 'SchedulerSession'

  # Returns a short one-liner of the Appointment details
  def label
    # eg. "Monday 1:30 pm to 2:00 pm"
    "#{start.strftime('%A')} #{pretty_start} to #{pretty_end}"
  end

  # Same label, but appended with the service provider.
  def label_with_service_provider
    label << ", with #{service_provider.display_name}"
  end

  # Returns a quick/n/short summary of the Appointment details
  def summary
    # TODO
  end

  def pretty_start
    "#{balance(start.hour)}:#{balance(start.to_datetime.minute)} #{meridian(start)}"
  end

  def pretty_end
    "#{balance(end_time.hour)}:#{balance(end_time.to_datetime.minute)} #{meridian(end_time)}"
  end


  private

  def balance(digit)
    return "0#{digit}" if digit.to_i < 10
    digit
  end

  def meridian(time)
    time.strftime('%p').upcase
  end

  alias_attribute :end_time, :end

end
