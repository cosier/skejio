class Skej::Twiml::Appointments::FinalizeAppointment < Skej::Twiml::BaseTwiml

  def sms
    build_twiml do |b|
      b.Message """
        Congratulations you have successfully booked your Appointment!\n
        Appointment Details:\n
        \n
        #{generate_appointment_details}
        \n
        __________ \n
        You are now finished booking, have a nice day! \n
        """

      b.Message """
        If you wish to book another appointment, \n
        just send us another message with your preferred Date and Time \n
        """
    end
  end

  def voice
    build_twiml do |b|
      b.Say "Congratulations you have successfully booked your Appointment!"
      b.Say "Here are your appointment details ..."
      b.say generate_appointment_details
      b.Say "...."
      b.say "You may now hang up, have a nice day!"
    end
  end


  def generate_appointment_details
    ap = options[:appointment]

    # TODO: customize this message further—
    # for example we can ommit the office if it is not important.
    # Same goes for service provider.
    #
    # Importance can be determined by the business settings,
    # and how the selection was made (forced, assumed, changed etc).
    #
    # For now we are just generating a very simple string with ALL the
    # relevant data for this appointment.
    details = """
      #{ap.start.strftime('%A')} the #{ap.start.day.ordinalize} at:\n
      #{ap.pretty_start} until #{ap.pretty_end}.
      With #{ap.service_provider}, at the #{ap.office} Office.
    """

    # Debug here

    # Return our details string
    details
  end

end
