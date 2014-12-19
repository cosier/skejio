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

  #validates_uniqueness_of :customer_id, :scope => :business_id
  after_save :log_changes

  enum device_type: [:voice, :sms]

  def state_machine
    ::SchedulerStateMachine.new(self, transition_class: ::SchedulerSessionTransition)
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

  private

  def log_changes
    if v = versions.last and v.event == "update" and v.changeset.present? and self.changed?
      meta = v.changeset["meta"]
      if meta
        before = JSON.parse(meta.first)
        after  = JSON.parse(meta.last)
        diff = {}

        after.map do |k,v|
          diff[k] = v if before[k] != after[k]
        end

        formatted_json = diff.to_json.gsub(',', ',<br/>').gsub(/^\{/, '').gsub(/\}$/, '')
        log "detected session store changes: <br/>\n<pre>#{formatted_json}</pre>"
      end
    end
  end




end
