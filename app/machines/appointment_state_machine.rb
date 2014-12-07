class AppointmentStateMachine < BaseMachine

  state :handshake, initial: true
  state :initial_input_date
  state :repeat_input_date
  state :display_results
  state :finalize_appointment

  transition from: :handshake, to: [:initial_input_date, :display_results]
  transition from: :initial_input_date, to: [:display_results, :initial_input_date]
  transition from: :repeat_input_date, to: [:initial_input_date, :repeat_input_date]
  transition from: :display_results, to: [:finalize_appointment, :repeat_input_date]

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

end
