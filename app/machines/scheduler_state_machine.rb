class SchedulerStateMachine < BaseMachine

  linear_states :handshake,
                :initial_decoder,
                :customer_registration,
                :office_selection,
                :service_selection,
                :provider_selection,
                :appointment_selection,
                :finished


  #############################################################
  # Global before / after hooks
  
  # Log every transition attempted
  before_transition do |session, transition|
    log "transitioning from: #{session.current_state}"
  end

  # Log every transition complete
  after_transition do |session, transition|
    key = session.current_state
    log "transitioned to: #{key}"
    session.process_logic
  end

  # Guard every transition with a default hash lookup for :complete
  guard_transition do |session|
    c = session.current_state.to_sym

    if session.store[c] == :complete
      log "TRANSITION APPROVED — current_state(#{session.current_state}) is complete"
      true

    elsif c == :retry || c == :handshake
      log "TRANSITION DEFAULT ALLOW - #{c.to_s}"
      true

    else
      log "TRANSITION DENIED — current_state(#{session.current_state}) completion required first."
      false
    end
  end

  # Retry catch all and loop back kicker
  after_transition :to => :retry do |session, transition|
    log "retrying -> #{session.last_available_state}"
    session.transition_to! session.last_available_state
  end

end
