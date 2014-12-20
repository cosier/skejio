module Skej
  module Twiml
    class FinalReport < BaseTwiml

      def sms
        ap = options[:appointment]

        build_twiml do |b|
          message = ""
          message << "Congratulations, you have successfully booked your Appointment!\n"
          message << "-------\n"
          message << "#{ap.start.strftime('%A')} the #{ap.start.day}#{ap.start.day.ordinalize}\n"
          message << "#{ap.chosen_service.display_name} #{provider_text} at #{ap.chosen_office}.\n"
          message << "During #{ap.pretty_start} - #{ap.pretty_end}"
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


