module Skej
  module StateLogic
    class CustomerRegistration < BaseLogic

      def think
      end

      def sms
        twiml do |r|
          r.Message """
          Welcome to the Customer Registration step.
          This step is currently under construction, please check back soon.
          """
        end
      end

      def voice
        twiml do |r|
          r.Say "Welcome to the Customer Registration step"
          r.Say "This step is currently under construction, please check back soon."
        end
      end

    end
  end
end

