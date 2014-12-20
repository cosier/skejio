class Skej::Twiml::Appointments::Summary < Skej::Twiml::BaseTwiml

  def sms
    build_twiml do |b|
      if options[:invalid_input]
        @invalid_input = "Sorry we did not recognize your selection \"#{options[:invalid_input]}\", please try again.\n-------\n"
      end

      start = options[:appointments].first.start

      message = ""

      # Prefix with invalid input message if exists
      message << (@invalid_input || "")

      # Start with the header
      message << generate_appointment_header

      # Dynamic change options
      message << "#{options[:options_menu]}\n"

      # Appointment selection list
      message << "Choose your appointment time (#{start.strftime('%A')} - #{start.day.ordinalize}):\n"
      message << options[:apps_menu]

      b.Message message.squeeze(' ')

    end
  end

  private

  def generate_appointment_header
    ap = options[:appointments].first

    provider_text = session.chosen_provider and "with #{session.chosen_provider.display_name}"

    details = """Showing available appointments for #{session.chosen_service.display_name}
    #{provider_text} at #{session.chosen_office.display_name}.\n"""

    # Return our details string, without any multiple spaces.
    details.squeeze(' ')
  end

end
