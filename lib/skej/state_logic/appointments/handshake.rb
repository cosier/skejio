class Skej::StateLogic::Appointments::Handshake < Skej::StateLogic::BaseLogic
  def think
    @apt   = @session.appointment_selection_state
    @state = @apt.state

    input = Skej::Warp.zone(@apt.store[:input_date].to_datetime, time_zone_offset) rescue nil

    # Load SMS users first initial date decoding
    if input.nil? and @session.sms? and @session.store[:initial_date_decoded].present?
      log "Loading SMS Sessions :initial_date_decoded captured via :initial_decoder state"

      date = Skej::NLP.parse(@session, @session.store[:initial_date_decoded])
      @apt.store[:appointment_input_date] = date.to_s
    end

    if input.present?
      log "Customer initial date input <strong>found:</strong><br/><pre>[:appointment_input_date => #{input.to_s}]</pre>"
      @apt.transition_to! :finalize_appointment
      #@apt.transition_to! :display_result

    else
      log "Customer initial date input <strong>not found:</strong><br/><pre>[:appointment_input_date => #{input || 'nil' }]</pre>"
      @apt.transition_to! :initial_input_date
    end

  end

  def sms_and_voice
    twiml_appointment_handshake
  end

end
