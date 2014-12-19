class Skej::StateLogic::Appointments::DisplayResult < Skej::StateLogic::BaseLogic

  def think

    @thinked = true
    @apt     = @session.apt
    @state   = @apt.state

    if @apt.store[:appointment_input_date].nil?
      # If we don't have a date determined yet,
      # send the Customer to the :repeat_input_date state for further selection.
      log ":input_date is empty, <strong>returning to :repeat_input_date</strong>"
      return @apt.transition_to! :repeat_input_date

    else
      # We have a new local date input, let's make sure we update
      # the parent session as well.
      @session.store! :appointment_input_date, @apt.store[:appointment_input_date]
    end

    if user_wants_change?
      log "customer requested time :change"
      clear_input!

      # Bail out of the think process now,
      # and go back to the :repeat_input_date for new date input.
      return @apt.transition_to! :repeat_input_date
    end

    process_result_selection
  end

  def sms_and_voice
    # Delegate rendering of the appointment display selection
    # to a sub TwiML view.
    #
    # The view receives just the appointments to render.
    twiml_appointments_display_results(appointments: @appointments)
  end

  private

    def process_result_selection
      # If the Customer has entered input,
      # we need to match it to one of the potential Appointments (ordered).
      #
      # The first condition (just_shown_results?) means that we require the previous
      # interaction to be the Appointment Results index.
      #
      # This guarantees we are processing the customer input at the right time.
      if just_shown_results? and (input = user_input?)

        # Normalize selection to an integer for precise hash lookup
        selected = input.to_i - 1

        # Clear this boolean as it's no longer true.
        clear_just_shown_flag!

        # Get the appointment from the ordered_appointents results.
        #
        # Here we are matching the users input as the index against an
        # ordered collection of Appointments.
        appointment = @appointments[selected - 1]

        # Make the appointment by committing to the database.
        # Will raise an exception immediately if not persisted successfully (!).
        appointment.save!

        log "customer chose appointment: <br/><pre>#{appointment.to_json}</pre>"
        @apt.store! :chosen_appointment_id, appointment.id

        log "advancing customer to appointment summary step"
        @apt.transition_to! :summary

      # If the customer wasn't just shown the results,
      # then the only thing left to do— is to show the results!
      else

        # Set a boolean on the session store, that we are showing results.
        just_shown_results!

        # Do nothing else, as the View provided by sms_and_voice,
        # will do the rest once the payload is requested via the Controller.
      end
    end

    # Check if we just shown the Customer results?
    #
    # This means, that the last interaction with the Customer
    # WAS the Appointment DisplayResults (results index).
    #
    # This is used in determining if we should process the input
    # as a selection or not (a logic safeguard)
    def just_shown_results?
      return true if get[just_shown_key]
    end

    # Mark things as true— used during result displaying
    def just_shown_results!
      get[just_shown_key] = true
    end

    # Clear this boolean flag (just_shown_key) on the @session.store hash
    # via the #get helper.
    def clear_just_shown_flag!
      get[just_shown_key] = false
    end

    # A static definition of the key for runtime error checking.
    # Or avoiding typos.
    def just_shown_key
      :appointment_results_just_shown
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
