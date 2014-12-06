class Skej::Twiml::Appointments::InitialDateInput < Skej::Twiml::BaseTwiml

    def sms(session)
      build_twiml do |b|
        b.Message """
        When would you like your next appointment?\n
        (eg. tomorrow, wednesday, 15th, week end)
        """
      end
    end

    def voice(session)
      build_twiml do |b|
        b.Say "Please select your next appointment date...."
        b.gather action: endpoint do |g|
          g.Say "Press 1 for Today"
          g.Say "Press 2 for Monday"
          g.Say "Press 3 for Wednesday"
          g.Say "Press 4 for Thursday"
          g.Say "Press 5 for Friday"
          g.Say "Press 6 for Saturday"
          g.Say "Press 7 for Sunday"
        end
      end
    end


end
