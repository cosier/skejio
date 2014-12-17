class BaseSession < ActiveRecord::Base
  include Statesman::Adapters::ActiveRecordQueries
  attr_accessor :twiml_sms, :twiml_voice, :twiml

  # This is an abstract parent class to provide basic Session functionality
  self.abstract_class = true

  # expose the state machine more naturally
  delegate :current_state,
    :process_state!,
    :can_transition_to?,
    :transition_to!,
    :available_events,
    to: :state_machine


  before_save :update_meta_store

  class << self

    def load(customer, business)
      sesh   = false

      # Find a session specific to this:
      # Business, Customer and within the last hour
      query  = { customer_id: customer.id,
                 business_id: business.id,
                 updated_at: 1.hour.ago..DateTime.now }

      existing = self.order(created_at: :desc).where(query).first

      if existing
        sesh = existing
        SystemLog.fact(title: self.name.underscore, payload: "loaded -> ID:##{sesh.id}")
      else
        sesh = self.create! query
        SystemLog.fact title: self.name.underscore, payload: "created -> ID:##{sesh.id}"
      end

      # seshion is now ready for use!
      sesh
    end

    def fresh(customer, business)
      properties  = { customer_id: customer.id, business_id: business.id }
      create! properties
    end

    def initial_state
      :handshake
    end

    def transition_class
      ::SchedulerSessionTransition
    end

  end

  def display_name
    "#{self.class.name.underscore}/##{id}"
  end

  def store
    # Hit the instance variable cache
    # Hit the Json eta field backing store
    # Instantiate a new fresh hash for the Session
    @store ||= ActiveSupport::HashWithIndifferentAccess.new((self.meta.present? and JSON.parse(self.meta)) || {})

  end

  # Lazy load this logic engine facade
  def logic(device = false, opts = {})
    @logic_cache ||= {}

    # The latest state for this session
    # (using the db as a mutex across multiple procs)
    fresh_state = self.class.find(id).current_state.to_sym

    # Build the engine and stash it into the hash cache
    @logic_cache[fresh_state] ||= logic_engine((device_type and device_type.to_sym) || device || params[:action])

    # New engine every time
    #logic_engine((device_type and device_type.to_sym) || device || params[:action])
  end

  def store!(key, value)
    SystemLog.fact(title: self.class.name.underscore, payload:"saving_session_metadata( <strong>#{key}</strong>, <strong>#{value}</strong> )")
    store[key] = value
    self.save!
  end

  def last_available_state
    prev = transitions.where.not(to_state: 'retry').order(created_at: :desc).first
    (prev and prev.to_state.to_sym) || :handshake
  end

  def chosen_office
    binding.pry
    Office.where(id: store[:chosen_office_id], business_id: business.id).first
  end

  # If you utilize the customer input to perform a permenanent side effect,
  # then make sure you clear the session input for the next state to behave correctly.
  #
  # As the next state may happen instantaneously, and not between http requests—
  # thus session input must be handled carefully from state to state, as not to get
  # contaminated.
  def clear_session_input!
    log "clearing session input to avoid state contamination"
    self.input.delete :Digits if self.input
    self.input.delete :Body if self.input
    params.delete :Digits if params
    params.delete :Body if params
  end

  def has_initial_date?
    # If we have an initial date from the initial_decoder,
    # then that means we have an initial date :)
    store[:initial_date_decoded].present?
  end

  def state
    state_machine
  end

  def update_meta_store
    self.meta = JSON.generate(store)
  end

  def update_meta_store!
    update_meta_store
    self.save!
  end

  def params
    RequestStore.store[:params]
  end

  def input
    params
  end

  private

  # Mini Logic factory
  def logic_engine(device)
    klass = "Skej::StateLogic::#{current_state.classify}".constantize
    engine = klass.new(session: self, device: device)
    engine
  end

  def log(msg)
    SystemLog.fact(title: self.class.name.underscore, payload: msg)
  end

end
