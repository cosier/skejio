class SchedulerStateMachine < BaseMachine

  linear_states :handshake,
                :initial_decoder,
                :customer_registration,
                :office_selection,
                :service_selection,
                :provider_selection,
                :appointment_selection,
                :finish


  #############################################################
  # Global before / after hooks

  # Log every transition attempted
  before_transition do |session, transition|
    log "transitioning from: #{session.current_state}"
  end

  # Log every transition complete
  after_transition do |session, transition|
    key = session.current_state.to_sym
    log "transitioned to: <strong>#{key}</strong>"

    # Run the logic processing
    session.logic.process!
  end

  # Guard every transition with a default hash lookup for :complete
  guard_transition do |session, tx|
    prev_state = session.state.last_state_by_priority.to_s
    curr_state = session.state.current_state.to_s

    # Validate the results of the logic processing.
    #
    # Passage onto the next state is governed only by the Logic module
    # responsible for that particular State.
    #
    # We accomplish this by checking the Session store to see if
    # the current Session state has a value of "complete".'
    #
    # Which will be explicitly set by the Logic module, if the state is truly complete.
    if session.store[curr_state] and session.store[curr_state].to_s == "complete"
      log """
        TRANSITION APPROVED — current_state(<strong>#{curr_state}</strong>) -> <strong>#{session.state.next_state_by_priority}</strong>
        <pre>session.store[#{curr_state}] == :complete</pre>
      """
      true

    # Always let retry or handshake pass
    elsif curr_state == "retry" || curr_state == "handshake"
      true

    # Looks like the Logic module for this specific state hasn't been executed yet.
    # or simply the Customer did not meet the Logic criteria to pass.
    #
    # So we return false, and let the Customer try again (by revaluating the logic think step).
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
