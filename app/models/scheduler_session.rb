# == Schema Information
#
# Table name: scheduler_sessions
#
#  id          :integer          not null, primary key
#  business_id :integer
#  customer_id :integer
#  created_at  :datetime
#  updated_at  :datetime
#  meta        :text
#  device_type :integer
#  is_finished :boolean          default(FALSE)
#  uuid        :string(255)
#

class SchedulerSession < BaseSession

  has_paper_trail

  belongs_to :customer
  belongs_to :business

  has_many :scheduler_session_transitions

  has_many :transitions,
    class_name: 'SchedulerSessionTransition',
    foreign_key: 'scheduler_session_id'

  has_many :appointment_selection_states
  has_one  :appointment_selection_state
  alias_attribute :apt, :appointment_selection_state

  validates_uniqueness_of :uuid
  after_save :log_changes
  before_save :prepare_uuid

  enum device_type: [:voice, :sms]

  delegate :chosen_appointment, to: :apt

  def state_machine
    ::SchedulerStateMachine.new(self, transition_class: ::SchedulerSessionTransition)
  end

  def appointment
    # Shared across the request
    @appoitment_cached ||= RequestStore.store[:appointment_session]
    return @appointment_cached if @appointment_cached.present?

    appointment = session.appointment_selection_states.first

    # Optionally create the entity unless it already exists
    appointment = AppointmentSelectionState.create(
      business_id: session.business_id,
      scheduler_session_id: session.id) unless appointment.present?

    # load this instance's device paramter from the original
    # session request
    appointment.device_type = device_type
    appointment.input = params

    # Update the request store
    RequestStore.store[:appointment_session] = appointment

    # Here's an AppointmentSelectionState ready to go!
    @appointment_cached ||= appointment
  end

  def reset_appointment_selection!
    store! :chosen_appointment_id, nil

    # Reset the sub appointment state machine
    appointment.state.transition_to! :handshake unless appointment.current_state.to_sym == :handshake

    # Main Session state goes back into time, unless we are already there.
    state.transition_to! :appointment_selection unless current_state.to_sym == :appointment_selection
  end

  # Based on the already set :chosen_office_id,
  # get the corresponding Office entity.
  def chosen_office
    query = { id: store[:chosen_office_id] || store[:chosen_office_selection_id], business_id: business.id }
    Office.where(query).first
  end

  # Based on the already set :chosen_provider_id,
  # get the corresponding ServiceProvider entity (User).
  def chosen_provider
    if cpi = store[:chosen_provider_id] and cpi.to_sym == :deferred
      return false
    else
      User.where(id: store[:chosen_provider_id] || store[:chosen_provider_selection_id], business_id: business.id).first
    end
  end

  # Based on the already set :chosen_service_id,
  # get the corresponding Service entity.
  def chosen_service
    Service.where(id: store[:chosen_service_id] || store[:chosen_service_selection_id], business_id: business.id).first
  end

  # Determines if we can show the name of the Service Provider during
  # Appointment Selection choices.
  def show_service_providers?

    # Get the specific Setting for the key Setting::USER_SELECTION,
    # specific to this business.
    setting = Setting.business(business).key(Setting::USER_SELECTION).first

    # Return the result of checking if the setting
    # value ==  Setting::USER_SELECTION_EXPRESS_I
    setting.is? Setting::USER_SELECTION_EXPRESS_I
  end

  # A more descriptive alias — deprecated
  # TODO: remove this usage throughout
  alias_attribute :show_service_providers_during_appointment_selection?, :show_service_providers?

  # Determines if the customer has the ability to change the default
  # Service.
  #
  # This is based on whether the service_selection setting has a value
  # of either, SERVICE_SELECTION_ASK or SERVICE_SELECTION_ASK_AND_ASSUME.
  def can_change_service?
    s = setting(Setting::SERVICE_SELECTION)
    s.is? Setting::SERVICE_SELECTION_ASK or s.is? Setting::SERVICE_SELECTION_ASK_AND_ASSUME
  end

  # Determines if it is possible to change the office.
  def can_change_office?
    s = setting(Setting::OFFICE_SELECTION)
    s.is? Setting::OFFICE_SELECTION_ASK or s.is? Setting::OFFICE_SELECTION_ASK_AND_ASSUME
  end

  # Determines if it is possible to change the provider.
  # Currently this is only supported through the FULL_CONTROL setting.
  def can_change_provider?
    s = setting(Setting::USER_SELECTION)
    s.is? Setting::USER_SELECTION_FULL_CONTROL
  end

end
