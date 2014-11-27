class SchedulerStateMachine
  include Statesman::Machine

  state :handshake, initial: true
  state :initial_decode
  state :customer_registration
  state :office_selection
  state :service_selection
  state :provider_selection
  state :appointment_selection
  state :finished
  state :error

  transition from: :handshake, to: [:initial_decode, :error]

  before_transition :to => :initial_decode do |session, transition|
    log title: 'SchedulerStateMachine', payload: 'transition -> :initial_decode'
  end

  after_transition :to => :error do |session, transition|
    error_payload = { session: session, transition: transition }
    SystemLog.fact(title: 'error', payload: "after_transition:error:#{error_payload.to_json}")
  end

  def next_state!
    transition_to! allowed_transitions.first
  end
  
  class << self
    def log(opts)
      SystemLog.fact(opts)
      Rails.logger.info "#{opts[:title]}: #{opts[:payload].to_json}"
    end
  end

end
