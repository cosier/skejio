class Skej::StateLogic::Appointments::Handshake < Skej::StateLogic::BaseLogic
  def think
    @apt   = session.appointment
    @state = @apt.state

    input = Skej::Warp.zone(@apt.store[:appointment_input_date].to_datetime, time_zone_offset) rescue nil

    # Load SMS users first initial date decoding
    if input.nil? and @session.sms? and @session.store[:initial_date_decoded].present?
      log "Loading SMS Sessions :initial_date_decoded captured via :initial_decoder state"

      input = Skej::NLP.parse(@session, @session.store[:initial_date_decoded])
      @apt.store! :appointment_input_date, input.to_s unless input.to_s.blank?

      # Since we just used this above, we need to clear it after (input state invalidation)
      @session.store[:initial_date_decoded] = nil
    end

    if input.present?
      log "Customer initial date input <strong>found:</strong><br/><pre>[:appointment_input_date => #{input.to_s}]</pre>"

      # Here we are routing only SMS to the specialized single summary page.
      if can_silently_assume?
        @apt.transition_to! :summary

      # Where as Voice users will be led to the appointment selection process.
      else
        @apt.transition_to! :display_result
      end

    else
      log "Customer initial date input <strong>not found:</strong><br/><pre>[:appointment_input_date => #{input || 'nil' }]</pre>"
      @apt.simple_id
      @apt.transition_to! :initial_input_date
    end

  end

  def sms_and_voice
    twiml_appointments_handshake
  end

end
