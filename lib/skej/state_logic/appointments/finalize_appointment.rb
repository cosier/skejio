class Skej::StateLogic::Appointments::FinalizeAppointment < Skej::StateLogic::BaseLogic

  def think
    @apt   = @session.apt
    @state = @apt.state
  end

  def sms_and_voice
    twiml do |b|
      b.Message "Finalize your appointment!"
    end
  end

end
