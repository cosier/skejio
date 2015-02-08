class Skej::StateLogic::Appointments::InitialInputDate < Skej::StateLogic::BaseLogic

  def think
    @apt   = @session.appointment
    @state = @apt.state
    @store = @session.store

    @options = {
      1 => "Today",
      2 => "Monday",
      3 => "Wednesday",
      4 => "Thursday",
      5 => "Friday",
      6 => "Saturday",
      7 => "Sunday"
    }
    
    # Predetermined user date input
    pinput = @store[:initial_date_decoded]

    # Check if we can abort early due to already having a date
    # This only applies for SMS users.
    if @session.sms? and pinput 
      log "Detected SMS User with Initial Date already set <span class='muted'>(#{pinput})</span>"
      # Now that we have used the :initial_date_decoded, make sure we clear it.
      # So that future attempts to change the date will be able to avoid this branch.
      @session.store! :initial_date_decoded, nil

      # And proceed to the next
      return save! pinput
    end

    if user_input?
      # Two possible types of input (:Body and :Digits)
      # Based on if the @session is sms? or voice?
      input = params[:Body] if @session.sms?
      input = @options[params[:Digits].to_i] if @session.voice? and params[:Digits].present?

      log "processed customer date selection: #{input}"

      # And proceed to the next
      return save! input
    end
  end

  def sms_and_voice
    # Generate the Twiml/Appointments/InitialInputDate view
    twiml_appointments_initial_input_date
  end


  private

  def save!(input)
    # Transform textual input into a Chronic date
    parsed_date = Skej::NLP.parse(@session, input)

    # Audit to logs
    log "using office time_zone offset: #{time_zone || 'none'}"

    daterized = parsed_date.to_datetime if parsed_date
    binding.pry
    
    # Apply a datetime offset shift, if the time_zone is available
    daterized = Skej::Warp.zone(daterized, time_zone_offset) if time_zone

    # Stash this datetime object as a string on the Appointment state
    @apt.store! :appointment_input_date, daterized.to_s
    clear_input!

    # Log and go to next
    log "setting <strong>appointment_input_date</strong> = <strong>#{daterized.to_s}</strong>"

    if can_silently_assume?
      @apt.transition_to! :summary
    else
      @apt.transition_to! :display_result
    end

  end


end
