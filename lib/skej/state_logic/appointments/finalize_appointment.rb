class Skej::StateLogic::Appointments::FinalizeAppointment < Skej::StateLogic::BaseLogic

  def think
    @apt   = @session.apt
    @state = @apt.state

    if @apt.store[:appointment_input_date].nil?
      # If we don't have a date determined yet,
      # send the Customer to the :repeat_input_date state for further selection.
      log ":input_date is empty, <strong>returning to :repeat_input_date</strong>"
      return @apt.transition_to! :repeat_input_date

    else
      # We have a new local date input, let's make sure we update
      # the parent session as well.
      @date = @apt.store[:appointment_input_date]
      @session.store! :appointment_input_date, @date
    end

    if user_wants_change?
      log "customer requested time :change"
      clear_input!

      # Bail out of the think process now,
      # and go back to the :repeat_input_date for new date input.
      return @apt.transition_to! :repeat_input_date
    end

    @appointments = query.available_now(@date)

  end

  def sms_and_voice
    twiml_appointments_finalize_appointment(appointments: @appointments)
  end

  private

    # Helper to determine if the Customer chose "Change".
    #
    # For voice users, we are currently mapping that to the digit 9 to
    # trigger the change selection.
    def user_wants_change?

      # Detect sms bodies for text "change"
      body = (b = params[:Body] and b.kind_of? String and b.include? "change")

      # Detect voice digits for the digit 9
      digits = (d = params[:Digits] and d.to_i == 9)

      # If any were true, change is wanted — otherwise it's not.
      body || digits
    end

end
