module Skej
  module Reply
    class SMSReply < BaseReply

      def build!

        twiml = build_twiml(@session)
        twiml.text
      end

      def build_twiml(opts = {})
        twiml = ::Twilio::TwiML::Response.new do |r|
          message = "Hello, we'll be right back."

          SystemLog.fact(title: 'reply:text', payload: message)
          r.Message message
        end
      end

    end
  end
end
