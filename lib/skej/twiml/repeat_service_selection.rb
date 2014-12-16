module Skej
  module Twiml
    class RepeatServiceSelection < BaseTwiml

      def sms(session)
        build_twiml do |b|
          b.Message "Sorry we did not recognize the option \"#{session.input[:Body]}\" "

          service_choices = ""
          options[:services].map do |index, service|
            service_choices << "Enter #{index} for #{service.name} \n"
          end

          b.Message service_choices

        end
      end

      def voice(session)
        build_twiml do |b|
          b.Gather action: endpoint(gathering: true), maxlength: 10, timeout: 120,  finishOnKey: "#", method: 'get' do |g|

            g.Say "Sorry please try again ..."

            g.Pause length: 1
            g.Say "Please select a Service for your Appointment"
            g.Pause length: 1
            g.Say "Followed by the pound key to continue"
            g.Pause length: 2

            options[:services].map do |index, service|
              g.Say "Enter #{index} for #{service.name} ...."
            end

            g.Pause length: 1
            g.Say "Press the pound key to listen to the available Services again"
          end # b.Gather

          # Fallback to a retry loop when the Customer times out
          b.Redirect endpoint
        end
      end

    end
  end
end


