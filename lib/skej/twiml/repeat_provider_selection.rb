module Skej
  module Twiml
    class RepeatProviderSelection < BaseTwiml

      def sms(session)
        build_twiml do |b|
          text = """
          Sorry we did not recognize the option \"#{session.input[:Body]}\" \n\n
          """

          options[:providers].map do |index, provider|
            text << "Enter #{index} for #{provider.display_name} \n"
          end

          b.Message text
        end
      end

      def voice(session)
        build_twiml do |b|
          b.Gather action: endpoint(gathering: true), maxlength: 10, timeout: 10,  finishOnKey: "#", method: 'get' do |g|

            g.Say "Sorry please try again ..."

            g.Pause length: 1
            g.Say "Please select a Provider for your Appointment"
            g.Pause length: 1
            g.Say "Followed by the pound key to continue"
            g.Pause length: 2

            options[:providers].map do |index, provider|
              g.Say "Enter #{index} for #{provider.display_name} ...."
            end

            g.Pause length: 1
            g.Say "Press the pound key to listen to the available Providers again"
          end # b.Gather

          # Fallback to a retry loop when the Customer times out
          b.Redirect endpoint
        end
      end

    end
  end
end


