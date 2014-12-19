class Skej::StateLogic::Appointments::Summary < Skej::StateLogic::BaseLogic

  def think
    @apt   = @session.apt
    @state = @apt.state

    # If we have an appointment already chosen,
    # then we have no business in this Summary— as we're already done!
    #
    # Now if you want to change the appointment and run this summary again,
    # then just delete the :chosen_appointment_id from the session store.
    #
    # Also voice users are automatically routed on as well.
    if @apt.chosen_appointment or not can_silently_assume?
      log "directing voice customer directly to appointment finish"
      return @apt.transition_to! :finish
    end

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

      # w
      # Bail out of the think process now,
      # and go back to the :repeat_input_date for new date input.
      return @apt.transition_to! :repeat_input_date
    end

    @appointments = query.available_now(@date)

    # Construct the menu options dynamically
    add_menu :service,  "Text <num> to change the Service" if session.can_change_service?
    add_menu :office,   "Text <num> to change the Office" if session.can_change_office?
    add_menu :provider, "Text <num> to change the Provider" if session.can_change_provider?
    add_menu :date,     "Text <num> to change the Date"

    # If we detect user input, then we need to start processing actions
    process_actions user_input?

    log "engaging sms customer appointment summary"
  end

  def sms_and_voice
    data = {
      appointments: @appointments,
      options_menu: option_menu,
      apps_menu:    appointment_menu
    }

    data[:invalid_input] = user_input? if @invalid_input.present?

    twiml_appointments_summary(data)
  end

  private

    def process_actions(original_input)
      # Normalize the customer input into an integer
      input = strip_to_int(original_input).to_i || 0

      # If we have an unrecognized input
      return invalid_input! if input < 1

      # Process Appointment selection
      if input > @menu_options.keys.length
        log "Processing Customer Appointment Selection: #{input}"
      # Process option handling (eg. change service / office)
      else
        key = @menu_options[input][:key]
        log "Processing Customer Option Selection: #{input} -> #{key}"
      end
    end

    def invalid_input!
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
