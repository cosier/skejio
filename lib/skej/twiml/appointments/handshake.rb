class Skej::Twiml::Appointments::Handshake < Skej::Twiml::BaseTwiml

    def sms(session)
      build_twiml do |b|
        b.Message "Welcome to Appointment Selection"
      end
    end

    def voice(session)
      build_twiml do |b|
        b.Say "Welcome to Appointment Selection"
      end
    end

end
