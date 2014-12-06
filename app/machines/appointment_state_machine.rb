class AppointmentStateMachine < BaseMachine

  state :handshake, initial: true
  state :initial_input_date
  state :repeat_input_date
  state :display_results
  state :finalize_appointment

end
