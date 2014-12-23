# == Schema Information
#
# Table name: appointment_selection_states
#
#  id                   :integer          not null, primary key
#  scheduler_session_id :integer          not null
#  business_id          :integer
#  created_at           :datetime
#  updated_at           :datetime
#  meta                 :text
#  device_type          :integer
#  is_finished          :boolean          default(FALSE)
#  uuid                 :string(255)
#

class AppointmentSelectionState < BaseSession
  has_paper_trail

  # Instance level storage of the device/request-type at hand
  # (:sms, :voice)
  attr_accessor :device, :input

  belongs_to :scheduler_session
  belongs_to :business

  has_many :appointment_selection_transitions
  enum device_type: [:voice, :sms]

  validates_uniqueness_of :uuid

  after_save :log_changes
  before_save :prepare_uuid

  class << self

    # Load a statemachine (AppointmentSelectionState -> AppointmentStateMachine)
    # instance for a given session.
    def machine(session)
      session.appointment
    end
  end

  def state_machine
    @state ||= ::AppointmentStateMachine.new(self, transition_class: ::AppointmentSelectionTransition)
  end

  def chosen_appointment
    Appointment.find store[:chosen_appointment_id] if store[:chosen_appointment_id].present?
  end

  def prepare!
  end

  private

  # Override base engine implementation to add the namespace "Appointments::"
  def logic_engine(device)
    klass = "Skej::StateLogic::Appointments::#{current_state.classify}".constantize
    engine = klass.new(session: scheduler_session, device: device)
    engine
  end

end
