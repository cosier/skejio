module Skej
  module Twiml
    class FinalReport < BaseTwiml

      def sms
        build_twiml do |b|
          b.Message generate_message
        end
      end

      def voice(session)
        ap = options[:appointment]
        build_twiml do |b|
          b.Message generate_message

          say = ""
          say << "Congratulations, you have successfully booked your Appointment!\n"
          say << "..."
          say << "#{ap.start.strftime('%A')} the #{ap.start.day.ordinalize} of #{ap.start.strftime("%B")}\n"
          say << "#{ap.service.display_name} #{options[:provider_text]} at #{ap.office.display_name}.\n"
          say << "During #{ap.pretty_start} - #{ap.pretty_end}\n"
          say << ".......\n"

          say << "If you want to edit your appointment — you can reference the appointment number: #{session.simple_id}....."
          say << "Once again, your appointment number is: #{session.simple_id}...."
          say << "Have a nice day!.. good bye..."

          b.Gather(url: endpoint) do |g|
            g.Say say
          end

        end
      end


      private

      def generate_message
        ap = options[:appointment]

        message = ""
        message << "Congratulations, you have successfully booked your Appointment!\n"
        message << "-------\n"
        message << "#{ap.start.strftime('%A')} the #{ap.start.day.ordinalize} of #{ap.start.strftime("%B")}\n"
        message << "#{ap.service.display_name} #{options[:provider_text]} at #{ap.office.display_name}.\n"
        message << "During #{ap.pretty_start} - #{ap.pretty_end}\n"
        message << "-------\n"
        message << "Your appointment number is: #{session.simple_id}\n"
        message << "If you want to edit your appointment — text \"change #{session.simple_id}\"\n"

        message.squeeze(' ')
      end

    end
  end
end


