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


  #############################################################
  # Global before / after hooks
  
  before_transition do |session, transition|
    log "transitioning from: #{session.current_state}"
  end

  after_transition do |session, transition|
    log "transitioned to: #{session.current_state}"
    session.install_twiml_reply
  end

  #############################################################
  # Specific transformation and transition logic

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

    session.transition_to! :customer_registration
  end

  after_transition :to => :customer_registration do |session, transition|
    session.install_twiml_reply
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

  guard_transition :from => :customer_registration, :to => :office_selection do |object|
    log 'denying transition to :office_selection — reason: not yet implemented'
    false
  end

  # Retry catch all and loop back kicker
  after_transition :to => :retry do |session, transition|
    log "retrying -> #{session.state_machine.last_transition.to_state}"
    session.transition_to! session.state_machine.last_transition.to_state
  end

end
