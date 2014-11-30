module Skej
  module Twiml
    class AskOfficeSelection < BaseTwiml

      def sms(session)
        build_twiml do |b|
          b.Message "Please select a Office for your Appointment"

          office_choices = ""
          options[:offices].map do |index, office|
            office_choices << "Enter #{index} for #{office.name} \n"
          end
          b.Message office_choices
        end
      end

      def voice(session)
        build_twiml do |b|
          b.Gather action: endpoint(gathering: true), maxlength: 10, timeout: 120,  finishOnKey: "#", method: 'get' do |g|

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
          end
        end
      end

    end
  end
end


