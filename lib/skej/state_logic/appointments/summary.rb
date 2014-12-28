class Skej::StateLogic::Appointments::Summary < Skej::StateLogic::BaseLogic

  def think
    @apt   = @session.appointment
    @state = @apt.state

    if @apt.store[:appointment_input_date].nil?
      if get[:initial_date_decoded]
        log ":initial_date_decoded found as a subsitute customer input_date"
      else
        # If we don't have a date determined yet,
        # send the Customer to the :repeat_input_date state for further selection.
        log ":input_date is empty, <strong>returning to :repeat_input_date</strong>"
        return @apt.transition_to! :repeat_input_date
      end

    else
      # We have a new local date input, let's make sure we update
      # the parent session as well.
      @date = @apt.store[:appointment_input_date]
      @session.store! :appointment_input_date, @date if @date
    end

    if @date.nil?
      log "date nil detected during summary display"
    end

    @appointments = query.available_on(@date) if @date

    # Construct the menu options dynamically
    add_menu :service,  "Text <num> to change the Service" if session.can_change_service?
    add_menu :office,   "Text <num> to change the Office" if session.can_change_office?
    add_menu :provider, "Text <num> to change the Provider" if session.can_change_provider?
    add_menu :date,     "Text <num> to change the Date"

    # If we detect user input, then we need to start processing actions
    process_actions if user_input?

    # If we have an appointment already chosen,
    # then we have no business in this Summary— as we're already done!
    #
    # Also voice users (defined by not#can_silently_assume?) are automatically routed on as well.
    if @apt.chosen_appointment.present? or not can_silently_assume?
      log "directing customer to appointment finish"
      return finish!
    end

    log "engaging sms customer appointment summary"
  end

  def sms_and_voice
    data = {
      appointments: @appointments,
      options_menu: option_menu,
      apps_menu:    appointment_menu
    }

    data[:invalid_input] = user_input? if @invalid_input.present?
    data[:insufficient_permission] = true if @insufficient_permission.present?

    twiml_appointments_summary(data)
  end

  private

    def process_actions(original_input = user_input?)
      # Normalize the customer input into an integer
      input = strip_to_int(original_input).to_i || 0
      option_length = @menu_options.keys.length

      # Since we are using the input for this state, we need to clear it.
      # Otherwise face massive recursiveness.
      clear_input!

      # If we have an unrecognized input
      return invalid_input! if input < 1

      # Process Appointment selection
      if input > option_length

        log "Processing Customer Appointment Selection: #{input}"
        appointment = @appointments[input - option_length - 1]

        # GUARD:
        # Handle bad input based on the existence of the appointment.
        return invalid_input! if appointment.nil?

        debug "you chose appointment: #{input} - #{appointment.label}"

        # Appointment Finalizer
        appointment.commit!

        @apt.store! :chosen_appointment_id, appointment.id
        finish!


      # Process option handling (eg. change service / office)
      else

        # GUARD:
        # Handle bad input based on the existence of the menu_options lookup.
        return invalid_input! if @menu_options[input].nil?

        key = @menu_options[input][:key]
        log "Processing Customer Option Selection: #{input} -> #{key}"

        # Branch logic for each possibility key
        case key

        when :office
          # GUARD: against malicious attempts
          return insufficient_permissions! unless  scheduler_session.can_change_office?

          debug "office selection"
          scheduler_session.retry! :office_selection

        when :service
          # GUARD: against malicious attempts
          return insufficient_permissions! unless  scheduler_session.can_change_service?

          debug "service selected"
          scheduler_session.retry! :service_selection

        when :provider
          # GUARD: against malicious attempts
          return insufficient_permissions! unless scheduler_session.can_change_provider?

          debug "provider selected"
          scheduler_session.retry! :provider_selection

        when :date
          # Customers are always allowed to change the date in all scenarios
          debug "date change selected"
          appointment_session.retry! :repeat_input_date

        else
          # This should actually not be reachable due to the return guard directly above.
          # But if it does happen, we'll know how.
          raise "Unmatched / Unkown Customer selection: #{input}:\n#{@menu_options.to_json}"
        end
      end
    end

    def insufficient_permissions!
      @insufficient_permission = true
    end

    def finish!
      # Don't forget about the top level session guard criteria
      @session.store! :appointment_selection, :complete

      # Let's go there
      @apt.transition_to :finish
    end

    def invalid_input!
      debug "your input was invalid: #{user_input?}" if user_input.present?
      @invalid_input = true
    end

    def add_menu(key, text)
      @menu_options ||= {}
      @menu_options[@menu_options.keys.length + 1] = { key: key, text: text }
    end

    def option_menu
      menu = ""
      @menu_options.each do |i, hash|
        menu << hash[:text].gsub('<num>', "#{i}") << " \n"
      end
      # return Compiled menu string
      menu
    end

    # Generates the menu listing for any additions appointments
    # provided to us by the logic module.
    #
    # Params:
    # +index+:: initial integer to start basing the appointment
    # listings off of (integer mappings for customer selection lookup).
    #
    def appointment_menu(index = @menu_options.keys.length)
      @appointments.map do |ap|
        # Increment our number count
        index = index + 1
        "Text #{index} for:  #{ap.pretty_start} to #{ap.pretty_end}\n"
      end.join
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
