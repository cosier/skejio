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

  class << self

    # Load a statemachine (AppointmentSelectionState -> AppointmentStateMachine)
    # instance for a given session.
    def machine(session)
      appointment = session.appointment_selection_states.first

      # Optionally create the entity unless it already exists
      appointment = AppointmentSelectionState.create(
        business_id: session.business_id,
        scheduler_session_id: session.id) unless appointment.present?

      # load this instance's device paramter from the original
      # session request
      appointment.device_type = session.device_type
      appointment.input = session.input || RequestStore.store[:params]

      # Here's an AppointmentSelectionState ready to go!
      appointment
    end
  end

  def state_machine
    @state ||= ::AppointmentStateMachine.new(self, transition_class: ::AppointmentSelectionTransition)
  end

  private

  # Override base engine implementation to add the namespace "Appointments::"
  def logic_engine(device)
    klass = "Skej::StateLogic::Appointments::#{current_state.classify}".constantize
    engine = klass.new(session: scheduler_session, device: device)
    engine
  end

end
