class SchedulerStateMachine < BaseMachine

  linear_states :handshake,
                :initial_decode,
                :customer_registration,
                :office_selection,
                :service_selection,
                :provider_selection,
                :appointment_selection,
                :finished


  #############################################################
  # Global before / after hooks
  
  before_transition do |session, transition|
    log "transitioning from: #{session.current_state}"
  end

  after_transition do |session, transition|
    key = session.current_state
    log "transitioned to: #{key}"
    session.install_twiml_reply
  end

  #############################################################
  # Specific transformation and transition logic

  after_transition :to => :handshake do |session, transition|
    log 'Welcome handshaking'
    session.store! :initial_decode, :complete
    session.transition_to! :initial_decode
  end

  after_transition :to => :initial_decode do |session, transition|
    if session.type == :sms
      log "sms session detected— engaging Chronic.parse(#{session.input[:Body]})"
      date = Chronic.parse(session.input[:Body])
      if date
        log "date extracted: #{date}"
      else
        log "no valid date detected: #{session.input[:Body]}"
      end
    else
      log "voice call initiate date decoding is not supported"
    end

    session.store! :initial_decode, :complete
    session.transition_to! :customer_registration
  end

  after_transition :to => :customer_registration do |session, transition|
  end

  after_transition :to => :office_selection do |session, transition|
    log 'Welcome to office_selection not yet implemented'
  end

  after_transition :to => :service_selection do |session, transition|
  end

  after_transition :to => :provider_selection do |session, transition|
  end

  after_transition :to => :appointment_selection do |session, transition|
  end

  after_transition :to => :finished do |session, transition|
  end

  guard_transition do |session|
    if session.store[session.current_state.to_sym] == "complete"
      log "TRANSITION APPROVED — current_state(#{session.current_state}) is complete"
      true
    else
      log "TRANSITION DENIED — current_state(#{session.current_state}) not completed"
      false
    end
  end

  # Retry catch all and loop back kicker
  after_transition :to => :retry do |session, transition|
    binding.pry
    log "retrying -> #{session.last_available_state}"
    session.transition_to! session.last_available_state
  end

end
