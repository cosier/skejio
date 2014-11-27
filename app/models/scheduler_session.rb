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
  has_paper_trail

  has_many :scheduler_session_transitions

  validates_uniqueness_of :customer_id, :scope => :business_id

  # expose the state machine more naturally
  delegate :current_state, :trigger!, :available_events, to: :state_machine

  class << self
    def load(customer, business)
      sesh = false
      query = { customer_id: customer.id, business_id: business.id }

      existing = SchedulerSession.where(query).first

      if existing
        sesh = existing
        SystemLog.fact(title: 'scheduler_session_loaded', payload: "##{sesh.id}")
      else
        sesh = SchedulerSession.create! query
        SystemLog.fact(title: 'scheduler_session_created', payload: "##{sesh.id}")
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
    SchedulerSessionStateMachine.new(self, transition_class: SchedulerSessionTransition)
  end

  private

end
