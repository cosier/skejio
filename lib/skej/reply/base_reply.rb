module Skej
  module Reply
    class BaseReply

      def initialize
      end
     
      def twiml
        @twiml ||= ::Twilio::TwiML::Response.new
      end

    end
  end
end
