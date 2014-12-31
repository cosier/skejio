class Skej::Twiml::Appointments::NoResult < Skej::Twiml::BaseTwiml

    def sms(session)
      build_twiml do |b|
        b.Message "Sorry, we did not find any available Appointments for #{options[:original_input] || 'your date'}\nPlease select a new date to search."
        b.Redirect endpoint
      end
    end

    def voice(session)
      build_twiml do |b|
        b.Say "Sorry.. we could not any available Appointments for your desired day...\n Please select a new date..."
        b.Redirect endpoint
      end
    end

end
