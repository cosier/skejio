class Skej::StateLogic::Appointments::RepeatDateInput < Skej::StateLogic::BaseLogic
  def think
    @apt = @sesion.appointment_selection_state

    log 'clearing current customer date input'
    @session.store! :initial_date_input, nil
    @apt.store! :input_date, nil

    log 'going back to :initial_date_input, now'
    @apt.transition_to! :initial_date_input
  end
end
