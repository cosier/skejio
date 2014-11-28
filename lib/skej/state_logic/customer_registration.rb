module Skej
  module StateLogic
    class CustomerRegistration < BaseLogic

      def think
      end

      def sms
        twiml do |r|
          r.Message "Welcome to #{@session.current_state.titleize}"
        end
      end

      def voice
      end

    end
  end
end

