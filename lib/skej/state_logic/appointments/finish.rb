class Skej::StateLogic::Appointments::Finish < Skej::StateLogic::BaseLogic
  def think
    @apt   = @session.appointment_selection_state
    @state = @apt.state

    # Transition the parent session state from
    # :appointment_selection -> :finish
    #
    # And we will leave the sub appointment state as is
    # (currently :finish as well)
    @session.state.transition_to! :finish

  end

end
