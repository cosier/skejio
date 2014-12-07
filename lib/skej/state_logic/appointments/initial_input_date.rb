class Skej::StateLogic::Appointments::InitialInputDate < Skej::StateLogic::BaseLogic

  def think
    @apt   = @session.appointment_selection_state
    @state = @apt.state

    @options = {
      1 => "Today",
      2 => "Monday",
      3 => "Wednesday",
      4 => "Thursday",
      5 => "Friday",
      6 => "Saturday",
      7 => "Sunday"
    }

    if user_input?
      if @session.sms?
        input = params[:Body]

      elsif @session.voice?
        input = @options[params[:Digits].to_i] if params[:Digits].present?

      else
        log 'not recognized session type'
      end

      daterized = Chronic.parse(input)
      daterized = daterized.to_datetime.change(offset: offset) if daterized

      log "processed customer date selection: #{daterized}"

      @apt.store[:input_date] = daterized.to_s
      @apt.transition_to! :display_results
    end

  end

  def sms_and_voice
    twiml_appointments_initial_input_date
  end


end
