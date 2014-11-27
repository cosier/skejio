module Skej
  module Reply
    class VoiceReply < BaseReply

      def build!
        twiml = ::Twilio::TwiML::Response.new do |r|
          message = "Sorry we're not available at the moment, please try again later."
          SystemLog.fact(title: 'audio_reply', payload: message)
          r.Say message
        end

        twiml.text
      end

    end
  end
end
