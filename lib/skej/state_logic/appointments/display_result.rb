class Skej::StateLogic::Appointments::DisplayResult < Skej::StateLogic::BaseLogic

  def think
    @thinked = true
    @apt   = @session.apt
    @state = @apt.state

    # Hash table for ordered indexing of appointments.
    # Which is used in the user selection phase as a decision selector.
    #
    # Generate a list of available time slots for this Session's Appointment
    @appointments = query.available_now

    if @apt.store[:input_date].nil?
      log ":input_date is empty, <strong>returning to :repeat_input_date</strong>"
      return @apt.transition_to! :repeat_input_date

    else
      @apt.store! :input_date, @apt.store[:input_date]
    end

    if user_wants_change?
      log "customer requested time :change"
      clear_input!
      return @apt.transition_to! :repeat_input_date
    end

    # If the Customer has entered input,
    # we need to match it to one of the potential Appointments (ordered)
    if input = user_input?
      # Normalize selection to an integer for precise hash lookup
      selected = input.to_i

      # Get the appointment from the ordered_appointents
      appointment = @appointments[selected]

      log "customer chose appointment: <br/><pre>#{appointment.to_json}</pre>"
      @apt.store! :chosen_appointment_id = appointment.save.id

      log "advancing customer to appointment finalization step"
      @apt.transition_to! :finalize_appointment
    end
  end

  def sms_and_voice
    # Delegate rendering of the appointment display selection
    # to a sub TwiML view.
    #
    # The view receives just the appointments to render.
    twiml_appointments_display_results(appointments: @appointments)
  end

  private

    # Memoize the query object based on this @session.
    def query
      @query ||= Skej::Appointments::Query.new(@session)
    end

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
