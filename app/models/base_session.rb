class BaseSession < ActiveRecord::Base
  include Statesman::Adapters::ActiveRecordQueries
  attr_accessor :input, :twiml_sms, :twiml_voice

  # This is an abstract parent class to provide basic Session functionality
  self.abstract_class = true

  has_paper_trail


  validates_uniqueness_of :customer_id, :scope => :business_id

  # expose the state machine more naturally
  delegate :current_state, :can_transition_to?, :transition_to!, :trigger!, :available_events, to: :state_machine

  enum device_type: [:voice, :sms]

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

  def store
    # Hit the instance variable cache
    # Hit the Json meta field backing store
    # Instantiate a new fresh hash for the Session
    @store ||= (self.meta.present? and JSON.parse(self.meta)) || {}
  end

  def store!(key, value)
    s = store
    s[key] = value
    @store = s
    self.save
  end

  def clear_twiml
    self.twiml_sms = Skej::Reply::SMSReply.new.twiml
    self.twiml_voice = Skej::Reply::VoiceReply.new.twiml
  end

  def install_twiml_reply
    case self.device_type.to_sym
    when :voice
      create_voice_twiml_reply
    when :sms
      create_sms_twiml_reply
    else
      raise "Session Device type unknown: #{self.device_type}"
    end
  end

  def create_sms_twiml_reply
      self.twiml_sms = 
        Skej::Reply::SMSReply.new(state: self.current_state, input: input).twiml
      raise 'Failed to create SMS TwiML Response' unless twiml_sms and twiml_sms.text
  end

  def create_voice_twiml_reply
      self.twiml_voice = 
        Skej::Reply::VoiceReply.new(state: self.current_state, input: input).twiml
      raise 'Failed to create Voice TwiML Response' unless twiml_voice and twiml_voice.text
  end

  def last_available_state
    transitions.where.not(to_state: 'retry').order(created_at: :desc).first.to_state.to_sym
  end

  private
  
  def update_meta_store
    self.meta = JSON.generate(store)
  end

end
