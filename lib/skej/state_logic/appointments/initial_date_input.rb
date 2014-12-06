class Skej::StateLogic::Appointments::InitialDateInput < Skej::StateLogic::BaseLogic

  def think
    @apt   = @session.appointment_selection_state
    @state = @apt.state

    @options = {
      1: "Today",
      2: "Monday",
      3: "Wednesday",
      4: "Thursday",
      5: "Friday",
      6: "Saturday",
      7: "Sunday",
    }

    if @session.sms?
      input = @session.input[:Body]

    elsif @session.voice?
      input = @options[@session.input[:Digits].to_i]

    else
      log 'not recognized session type'
    end

    daterized = Chronic.parse(input).change(offset: offset)
    log "processed customer date selection: #{daterized}"

    @apt.store[:input_date] = daterized.to_s
    @apt.transition_to! :display_results

  end

  def sms_and_voice
    twiml_appointment_initial_date_input
  end


end
