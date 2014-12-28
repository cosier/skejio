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
#  service_id            :integer          not null
#

class Appointment < ActiveRecord::Base


  belongs_to :service_provider,
    class_name: 'User'

  belongs_to :office
  belongs_to :business
  belongs_to :customer
  belongs_to :service

  belongs_to :session,
    foreign_key: 'created_by_session_id',
    class_name: 'SchedulerSession'

  after_create :log_creation

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

  # Responsible for finalizing an appointment
  def commit!
    save! unless persisted?
  end


  private

  def balance(digit)
    return "0#{digit}" if digit.to_i < 10
    digit
  end

  def meridian(time)
    time.strftime('%p').upcase
  end

  def log_creation
    SystemLog.fact(title: self.class.name.underscore, payload: "Created Appointment: <br/><pre>#{JSON.pretty_generate(JSON.parse(self.to_json))}</pre>")
  end

  alias_attribute :end_time, :end
  alias_attribute :start_time, :start

end
