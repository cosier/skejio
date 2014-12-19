class Skej::Twiml::Appointments::Summary < Skej::Twiml::BaseTwiml

  def sms
    build_twiml do |b|
      b.Message "#{generate_appointment_header}#{options[:options_menu]}\nChoose your appointment time:\n#{options[:apps_menu]}
      ".squeeze(' ')

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
