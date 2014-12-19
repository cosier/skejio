module Skej
  module Twiml
    class RepeatOfficeSelection < BaseTwiml

      def sms(session)
        build_twiml do |b|
          text = "Sorry we did not recognize the option \"#{session.input[:Body]}\" \n\n"

          options[:offices].map do |index, office|
            text << "Enter #{index} for #{office.name} \n"
          end

          b.Message text

        end
      end

      def voice(session)
        build_twiml do |b|
          b.Gather action: endpoint(gathering: true), maxlength: 10, timeout: 10,  finishOnKey: "#", method: 'get' do |g|

            g.Say "Sorry please try again ..."

            g.Pause length: 1
            g.Say "Please select a Office for your Appointment"
            g.Pause length: 1
            g.Say "Followed by the pound key to continue"
            g.Pause length: 2

            options[:offices].map do |index, office|
              g.Say "Enter #{index} for #{office.name} ...."
            end

            g.Pause length: 1
            g.Say "Press the pound key to listen to the available Offices again"
          end # b.Gather

          # Fallback to a retry loop when the Customer times out
          b.Redirect endpoint
        end
      end

    end
  end
end


