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
          b.Say "After recording your name after the beep, press any key to continue."
          b.Record maxlength: 10, method: 'get', action: endpoint
        end.text
      end

    end
  end
end


