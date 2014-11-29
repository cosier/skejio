class BaseSession < ActiveRecord::Base
  include Statesman::Adapters::ActiveRecordQueries
  attr_accessor :input, :twiml_sms, :twiml_voice

  # This is an abstract parent class to provide basic Session functionality
  self.abstract_class = true

  enum device_type: [:voice, :sms]

  # expose the state machine more naturally
  delegate :current_state,
    :process_state!,
    :can_transition_to?,
    :transition_next!,
    :transition_to!,
    :available_events,
    to: :state_machine


  before_save :update_meta_store

  class << self

    def load(customer, business)
      sesh   = false
      query  = { customer_id: customer.id, business_id: business.id }

      existing = self.where(query).first
      log_title = self.name.underscore

      if existing
        sesh = existing
        SystemLog.fact(title: log_title, payload: "loaded -> ID:##{sesh.id}")
      else
        sesh = self.create! query
        SystemLog.fact title: log_title, payload: "created -> ID:##{sesh.id}"
      end

      # seshion is now ready for use!
      sesh
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
    # Hit the Json meta field backing store
    # Instantiate a new fresh hash for the Session
    @store ||= (self.meta.present? and JSON.parse(self.meta)) || {}
  end

  def store!(key, value)
    SystemLog.fact(title: self.class.name.underscore, payload:"saving_session_metadata( <strong>#{key}</strong>, <strong>#{value}</strong> )")
    col = store
    col[key] = value
    @store = col
    self.save!
  end

  def last_available_state
    prev = transitions.where.not(to_state: 'retry').order(created_at: :desc).first
    (prev and prev.to_state.to_sym) || :handshake
  end

  def process_logic
    self.send "process_#{device_type.to_s}_logic"
  end

  def think!
    log "activating logic_engine -> behaviour(think!)"
    logic_engine(device_type.to_sym).thinker
  end

  def clear_input_body!
    raise "Session input unavailable" if self.input.nil?
    self.input.delete :Body
  end

  private

  def process_sms_logic
    logic_engine(:sms).process!
  end

  def process_voice_logic
    logic_engine(:voice).process!
  end

  def logic_engine(device)
    state = self.current_state
    klass = "Skej::StateLogic::#{state.classify}".constantize
    engine = klass.new(session: self, device: device)
    engine
  end

  def update_meta_store
    self.meta = JSON.generate(store)
  end

  def log(msg)
    SystemLog.fact(title: self.class.name.underscore, payload: msg)
  end

end
