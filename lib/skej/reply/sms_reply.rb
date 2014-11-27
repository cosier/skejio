module Skej
  module Reply
    class SMSReply < BaseReply

      def build!
        twiml = ::Twilio::TwiML::Response.new do |r|
          message = "Hello, we'll be right back."

          SystemLog.fact(title: 'text_reply', payload: message)
          r.Message message
        end

        twiml.text
      end

    end
  end
end
