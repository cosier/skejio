module Skej
  module Twiml
    class AskServiceSelection < BaseTwiml

      def sms(session)
        build_twiml do |b|
          if options[:service_confirming_assumption].present? and not options[:ask].present?
            b.Message """We have chosen the service #{options[:default].name} for you.
            \n Would you like to like to change it? (enter yes/no)"""

          else
            service_choices = "Please select a Service for your Appointment:\n"
            options[:services].map do |index, service|
              service_choices << "Enter #{index} for #{service.name} \n"
            end

            b.Message service_choices
          end

        end
      end

      def voice(session)
        build_twiml do |b|
          b.Gather action: endpoint(gathering: true), maxlength: 10, timeout: 120,  finishOnKey: "#", method: 'get' do |g|

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
          end
        end
      end

    end
  end
end


