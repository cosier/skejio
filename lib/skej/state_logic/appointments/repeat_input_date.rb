class Skej::StateLogic::Appointments::RepeatInputDate < Skej::StateLogic::BaseLogic
  def think
    @apt = @session.apt

    log 'clearing current customer date input'
    @session.store! :initial_date_input, nil
    @apt.store! :input_date, nil

    @session.input[:Body] = nil
    @session.input[:Digits] = nil

    params.delete :Body
    params.delete :Digits

    log 'going back to :initial_date_input, now'
    @apt.transition_to! :initial_input_date

  end


  def sms_and_voice
  end

end
