class SchedulerStateMachine < BaseMachine

  linear_states :handshake,
                :initial_decode,
                :customer_registration,
                :office_selection,
                :service_selection,
                :provider_selection,
                :appointment_selection,
                :finished

  # loopback state
  state :retry

  before_transition do |session, transition|
    log "transitioning from: #{session.current_state}"
  end

  after_transition do |session, transition|
    log "transitioned to: #{session.current_state}"
    session.clear_twiml
  end

  after_transition :to => :initial_decode do |session, transition|
  end

  after_transition :to => :customer_registration do |session, transition|
  end

  after_transition :to => :office_selection do |session, transition|
  end

  after_transition :to => :service_selection do |session, transition|
  end

  after_transition :to => :provider_selection do |session, transition|
  end

  after_transition :to => :appointment_selection do |session, transition|
  end

  after_transition :to => :finished do |session, transition|
  end

  # Retry catch all and loop back kicker
  after_transition :to => :retry do |session, transition|
    log "retrying -> #{session.state_machine.last_state}"
    transition_to! session.last_transition.to_state
  end

end
