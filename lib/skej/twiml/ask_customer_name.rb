module Skej
  module Twiml
    class AskCustomerName < BaseTwiml

      def sms(session)
        build_twiml do |b|
          b.Message """
          Welcome to the Scheduler App!\n
          To get started please tell us your full name.
          """
        end
      end

      def voice(session)
        build_twiml do |b|
          b.Say "To get started please tell us your full name...."

          b.Say "Record your name after the beep..."
          b.Say "Then Press the pound key to continue"

          b.Record maxlength: 10, timeout: 10,  finishOnKey: "#", method: 'get', action: endpoint
        end
      end

    end
  end
end


