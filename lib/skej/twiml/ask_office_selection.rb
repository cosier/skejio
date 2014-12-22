module Skej
  module Twiml
    class AskOfficeSelection < BaseTwiml

      def sms(session)
        build_twiml do |b|
          if options[:office_selection_confirming_assumption].present? and not options[:ask].present?
            b.Message "We have chosen the office #{options[:default].name} for you.\nWould you like to like to change it? (enter yes/no)"

          else
            office_choices = "Please select a Office for your Appointment:\n"
            options[:offices].map do |index, office|
              office_choices << "Enter #{index} for #{office.name} \n"
            end
            b.Message office_choices
          end

        end
      end

      def voice(session)
        build_twiml do |b|
          option_length = Math.log10(options[:offices].length).to_i + 1

          b.Gather action: endpoint(gathering: true), maxlength: option_length , timeout: 10,  finishOnKey: "#", method: 'get' do |g|

            if options[:office_selection_confirming_assumption].present? and not options[:ask].present?
              log "Asking the Customer for Assumption confirmation"
              g.Say "We have chosen the office #{options[:default].name} for you. ...."
              g.Say "Press 1 to change this office ...."
              g.Say "Press 2 to keep this office ...."
              g.Say "When you are finished, ... press the pound key to continue ..."

            else
              log "Asking the Customer for Office Selection"

              g.Say "Please select a Office for your Appointment ...."
              g.Say "Followed by the pound key to continue"
              g.Pause length: 2

              options[:offices].map do |index, office|
                g.Say "Enter #{index} for #{office.name} ...."
              end

              g.Pause length: 1
              g.Say "Press the pound key to listen to the available Offices again"
            end

          end # b.Gather

          # Fallback to a retry loop when the Customer times out
          b.Redirect endpoint
        end
      end

    end
  end
end


