module Skej
  module StateLogic
    class CustomerRegistration < BaseLogic

      def think
        if store[:customer_name]
        end
      end

      def sms
        if store[:customer_name].nil?
          twiml_ask_customer_first_name
        end
      end

      def voice
        twiml_ask_customer_name
      end


    end
  end
end

