module Skej
  module Twiml
    class FinalReport < BaseTwiml

      def sms
        ap = options[:appointment]

        build_twiml do |b|
          message = ""
          message << "Congratulations, you have successfully booked your Appointment!\n"
          message << "-------\n"
          message << "#{ap.start.strftime('%A')} the #{ap.start.day.ordinalize}\n"
          message << "#{ap.service.display_name} #{options[:provider_text]} at #{ap.office.display_name}.\n"
          message << "During #{ap.pretty_start} - #{ap.pretty_end}\n"
          message << "-------\n"
          message << "If you want to edit your appointment — text \"change #{session.simple_id}\"\n"

          b.Message message.squeeze(' ')
        end
      end

      def voice(session)
        build_twiml do |b|
          b.Say "Your final appointment report is on the way!"
        end
      end

    end
  end
end


