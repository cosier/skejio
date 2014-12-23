class Skej::StateLogic::Appointments::Finish < Skej::StateLogic::BaseLogic
  def think
    @apt   = @session.appointment
    @state = @apt.state

    # At this point, this state is already completed.
    mark_as_completed!

    # Transition the parent session state from
    # :appointment_selection -> :finish
    #
    # And we will leave the sub appointment state as is
    # (currently :finish as well)
    @session.state.transition_to! :finish unless @session.state.current_state.to_sym == :finish

  end

end
