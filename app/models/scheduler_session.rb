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
#  type        :integer
#

class SchedulerSession < ActiveRecord::Base
  include Statesman::Adapters::ActiveRecordQueries
  has_paper_trail

  attr_accessor :input, :twiml_sms, :twiml_voice

  has_many :scheduler_session_transitions

  validates_uniqueness_of :customer_id, :scope => :business_id

  # expose the state machine more naturally
  delegate :current_state, :transition_to!, :trigger!, :available_events, to: :state_machine

  enum type: [:voice, :sms]

  class << self
    def load(customer, business)
      sesh = false
      query = { customer_id: customer.id, business_id: business.id }

      existing = SchedulerSession.where(query).first

      if existing
        sesh = existing
        SystemLog.fact(title: 'scheduler_session', payload: "loaded -> SchedulerSession:###{sesh.id}")
      else
        sesh = SchedulerSession.create! query
        SystemLog.fact title: 'scheduler_session', payload: "created -> SchedulerSession:##{sesh.id}"
      end

      # seshion is now ready for use!
      sesh
    end

    def transition_class
      ::SchedulerSessionTransition
    end

    def initial_state
      :handshake
    end
  end


  def state_machine
    ::SchedulerStateMachine.new(self, transition_class: ::SchedulerSessionTransition)
  end

  def clear_twiml
    self.twiml_sms = Skej::Reply::SMSReply.new.twiml
    self.twiml_voice = Skej::Reply::VoiceReply.new.twiml
  end

  def install_twiml_reply
    case self.type.to_sym
    when :sms
      self.twiml_sms = 
        Skej::Reply::SMSReply.new(state: self.current_state, input: input).twiml
    when :sms
      self.twiml_voice = 
        Skej::Reply::VoiceReply.new(state: self.current_state, input: input).twiml
    end
  end

  private

end
