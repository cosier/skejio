module Skej
  module Reply
    
    class << self
      def sms(opts)
        reply = Skej::Reply::SMSReply.new(opts)
        reply.build!
      end

      def voice(opts)
        reply = Skej::Reply::VoiceReply.new(opts)
        reply.build!
      end
    end

  end
end
