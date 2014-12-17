module Skej
  module Twiml
    class AskServiceSelection < BaseTwiml

      def sms(session)
        build_twiml do |b|
          if options[:service_selection_confirming_assumption].present? and not options[:ask].present?
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
          option_length = Math.log10(options[:services].length).to_i + 1

          b.Gather action: endpoint(gathering: true), maxlength: option_length , timeout: 10,  finishOnKey: "#", method: 'get' do |g|

            if options[:service_selection_confirming_assumption].present? and not options[:ask].present?
              log "Asking the Customer for Assumption confirmation"
              g.Say "We have chosen the service #{options[:default].name} for you. ...."
              g.Say "Press 1 to change this service ...."
              g.Say "Press 2 to keep this service ...."
              g.Say "When you are finished, ... press the pound key to continue ..."

            else
              log "Asking the Customer for Service Selection"

              g.Say "Please select a Service for your Appointment ...."
              g.Say "Followed by the pound key to continue"
              g.Pause length: 2

              options[:services].map do |index, service|
                g.Say "Enter #{index} for #{service.name} ...."
              end

              g.Pause length: 1
              g.Say "Press the pound key to listen to the available Services again"
            end

          end # b.Gather

          # Fallback to a retry loop when the Customer times out
          b.Redirect endpoint
        end
      end

    end
  end
end


