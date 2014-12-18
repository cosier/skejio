class Skej::StateLogic::Appointments::FinalizeAppointment < Skej::StateLogic::BaseLogic

  def think
    @apt   = @session.apt
    @state = @apt.state
  end

  def sms_and_voice
    twiml_appointments_finalize_appointment(appointment: @apt.chosen_appointment)
  end

end
