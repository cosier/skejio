class Skej::Twiml::Appointments::Handshake < Skej::Twiml::BaseTwiml

    def sms
      build_twiml do |b|
        b.Message "Welcome to Appointment Selection"
      end
    end

    def voice
      build_twiml do |b|
        b.Say "Welcome to Appointment Selection"
      end
    end

end
