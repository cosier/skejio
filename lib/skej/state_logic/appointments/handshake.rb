class Skej::StateLogic::Appointments::Handshake < Skej::StateLogic::BaseLogic
  def think
    @apt   = @session.appointment_selection_state
    @state = @apt.state

    input = @apt.store[:input_date].to_datetime.in_time_zone(time_zone) rescue nil

    # Load SMS users first initial date decoding
    if input.nil? and @session.sms? and @session.store[:initial_date_input].present?
      log "Loading SMS Sessions :initial_date_input captured via :initial_decoder state"
      input = @session.store[:initial_date_input].to_datetime.in_time_zone(time_zone) rescue nil
      @apt.store[:input_date] = input.to_s
    end

    if input.present?
      log "Customer initial date input <strong>found:</strong><br/><pre>[:input_date => #{input.to_s}]</pre>"
      @apt.transition_to! :display_results

    else
      log "Customer initial date input <strong>not found:</strong><br/><pre>[:input_date => #{@apt[:input_date] || 'nil' }]</pre>"
      @apt.transition_to! :initial_input_date
    end

  end

  def sms_and_voice
    twiml_appointment_handshake
  end

end
