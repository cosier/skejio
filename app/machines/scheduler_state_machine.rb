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
    binding.pry
    key = session.current_state.to_sym
    log "transitioned to: <strong>#{key}</strong>"

    # Run the logic processing
    session.logic.process!
  end

  # Guard every transition with a default hash lookup for :complete
  guard_transition do |session, tx|
    prev_state = session.state.last_state_by_priority.to_s
    curr_state = session.state.current_state.to_s

    # Validate the results of the logic processing
    if session.store[curr_state] and session.store[curr_state].to_s == "complete"
      log "TRANSITION APPROVED — current_state(<strong>#{curr_state}</strong>) passed"
      true

    elsif curr_state == "retry" || curr_state == "handshake"
      #log "TRANSITION DEFAULT ALLOW - #{c.to_s}"
      true

    else
      log "TRANSITION DENIED — current_state(<strong>#{curr_state}</strong>) is incomplete"
      false
    end
  end

  # Retry catch all and loop back kicker
  after_transition :to => :retry do |session, transition|
    log "retrying -> #{session.last_available_state}"
    session.transition_to! session.last_available_state
  end

end
