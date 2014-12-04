module Skej
  module Twiml
    class AskProviderSelection < BaseTwiml

      def sms(session)
        build_twiml do |b|
          b.Message "Please select a Provider for your Appointment"

          provider_choices = ""
          options[:providers].map do |index, provider|
            provider_choices << "Enter #{index} for #{provider.display_name} \n"
          end
          b.Message provider_choices
        end
      end

      def voice(session)
        build_twiml do |b|
          b.Gather action: endpoint(gathering: true), maxlength: 10, timeout: 10,  finishOnKey: "#", method: 'get' do |g|

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


