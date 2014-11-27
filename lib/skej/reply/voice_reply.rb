module Skej
  module Reply
    class VoiceReply < BaseReply

      def build!
        twiml = build_twiml
        twiml.text
      end

      def build_twiml(opts = {})
        twiml = ::Twilio::TwiML::Response.new do |r|
          message = "Sorry we're not available at the moment, please try again later."
          SystemLog.fact(title: 'reply:voice', payload: message)
          r.Say message
        end
      end

    end
  end
end
