module Skej
  module Twiml
    class AskServiceSelection < BaseTwiml

      def sms(session)
        build_twiml do |b|
          b.Message "Please select a Service for your Appointment"

          service_choices = ""
          options[:services].map do |index, service|
            service_choices << "Enter #{index} for #{service.name} \n"
          end

          b.Message services_choices

        end
      end

      def voice(session)
        build_twiml do |b|
          b.Gather action: endpoint(gathering: true), maxlength: 10, timeout: 120,  finishOnKey: "#", method: 'get' do |g|
            g.Say "Please select a Service for your Appointment, followed by the pound key to continue"

            options[:services].map do |index, service|
              g.Say "Enter #{index} for #{service.name}"
            end

            g.Say "Press the pound key to listen to the available Services again"
          end
        end
      end

    end
  end
end


