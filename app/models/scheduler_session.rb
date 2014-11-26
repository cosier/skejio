# == Schema Information
#
# Table name: sessions
#
#  id          :integer          not null, primary key
#  business_id :integer
#  customer_id :integer
#  created_at  :datetime
#  updated_at  :datetime
#

class SchedulerSession < ActiveRecord::Base
  include Statesman::Adapters::ActiveRecordQueries

  has_many :scheduler_session_transitions

  validates_uniqueness_of :customer_id, :scope => :business_id

  # expose the state machine more naturally
  delegate :current_state, :trigger!, :available_events, to: :state_machine

  class << self
    def load(customer, business)
      sesh = false
      query = { customer_id: customer.id, business_id: business.id }

      existing = Session.where(query).first
      if existing
        sesh = existing
        SystemLog.fact(title: 'session_loaded', payload: "SESSION:#{sesh.id}")
      else
        sesh = Session.create! query
        SystemLog.fact(title: 'session_created', payload: "SESSION:#{sesh.id}")
      end

      # seshion is now ready for use!
      sesh
    end

    def transition_class
      SessionTransition
    end

    def initial_state
      :handshake
    end
  end


  def state_machine
    SessionStateMachine.new(self, transition_class: SessionTransition)
  end

  private

end
