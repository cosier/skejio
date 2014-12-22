class Skej::Twiml::Appointments::Summary < Skej::Twiml::BaseTwiml

  def sms
    build_twiml do |b|

      if options[:invalid_input]
        @error = "Sorry we did not recognize your selection \"#{options[:invalid_input]}\", please try again.\n-------\n"
      end

      if options[:insufficient_permission]
        @error = "Sorry you we cannot change that for this Appointment.\nPlease try another selection below.\n"
      end

      start = options[:appointments].first.start

      # Init the message character container
      message = ""

      message << options[:debug] if options[:debug]

      # Prefix with any error message — if exists
      message << @error if @error.present?

      # Start with the header
      message << generate_appointment_header

      # Dynamic change options
      message << "#{options[:options_menu]}\n"

      # Appointment selection list
      message << "Choose your appointment time (on #{start.strftime('%A')} the #{start.day.ordinalize}):\n"
      message << options[:apps_menu]

      b.Message message.squeeze(' ')

    end
  end

  # This should not be reachable,
  # due to special re-routing in the parent logic module.
  def voice
    raise "No Voice TwiML view implemented for Summary state"
  end

  private

  def generate_appointment_header
    ap = options[:appointments].first

    provider_text = session.chosen_provider and " with #{session.chosen_provider.display_name}"

    details = "Showing available appointments for #{session.chosen_service.display_name} "
    details << provider_text if provider_text
    details << "at #{session.chosen_office.display_name}.\n"

    # Return our details string, without any multiple spaces.
    details.squeeze(' ')
  end

end
