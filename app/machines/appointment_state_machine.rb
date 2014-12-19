class AppointmentStateMachine < BaseMachine

  state :handshake, initial: true
  state :initial_input_date
  state :repeat_input_date
  state :display_result
  state :summary
  state :finish

  transition from: :handshake, to: [:initial_input_date, :display_result, :summary]
  transition from: :initial_input_date, to: [:display_result, :initial_input_date, :repeat_input_date, :summary]
  transition from: :repeat_input_date, to: [:initial_input_date, :repeat_input_date]
  transition from: :display_result, to: [:summary, :repeat_input_date]
  transition from: :summary, to: [:repeat_input_date, :finish]

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
