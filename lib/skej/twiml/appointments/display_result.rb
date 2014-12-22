class Skej::Twiml::Appointments::DisplayResult < Skej::Twiml::BaseTwiml

  def sms(session)
    build_twiml do |b|
      # Use a single message to accomplish
      # the entire visual selection.
      message = ""
      message << "Here are your next available Appointments: \n"
      message << generate_appointment_list
      message << "\n"
      message << "____\n"
      message << "send *change* to choose a different appointment time."

      b.Message(message)
    end
  end

  def voice(session)
    build_twiml do |b|
      b.Gather action: endpoint do |g|
        b.Say "Here are your next available Appointments:"
        b.Say generate_appointment_list

        b.Say "Press 9 to choose another Date"
      end
    end
  end

  private

    def generate_appointment_list
      # Empty string container
      list = ""

      # Iterate over all given appointments to produce a
      # visual selection list.
      options[:appointments].each_with_index do |apt, index|

        # Determine if we can show Service Provider names inline with
        # the Appointment Label.
        if options[:session].show_service_providers?
          list << "#{index + 1} - #{apt.label_with_service_provider} \n"
        else
          list << "#{index + 1} - #{apt.label} \n"
        end

      end

      # Return string compilation containing visual selection list.
      list
    end


end
