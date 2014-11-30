module Skej
  module Twiml
    class AskCustomerName < BaseTwiml

      def sms(session)
        build_twiml do |b|
          b.Message "Welcome to the Scheduling System, to get started please tell us your full name."
        end.text
      end

      def voice(session)
        build_twiml do |b|
          b.Say "Welcome to the Scheduling System, to get started please tell us your full name"
          b.Say "After recording your name after the beep, press the pound key to continue."
          b.Record maxlength: 10, timeout: 10,  finishOnKey: "#", method: 'get', action: endpoint
        end
      end

    end
  end
end


