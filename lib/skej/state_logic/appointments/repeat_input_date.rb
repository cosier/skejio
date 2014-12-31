class Skej::StateLogic::Appointments::RepeatInputDate < Skej::StateLogic::BaseLogic

  def think
    @apt = @session.appointment

    log 'clearing current customer date input'
    @session.store! :initial_date_decoded, nil
    @session.store! :initial_date_input, nil
    @session.store! :initial_input_date, nil

    @apt.store! :input_date, nil if @apt.store[:input_date].present?

    log 'going back to :initial_date_input, now'

    @apt.transition_to! :initial_input_date
  end


  def sms_and_voice
  end

end
