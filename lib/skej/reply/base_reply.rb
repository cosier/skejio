module Skej
  module Reply
    class BaseReply

      def initialize(opts)
        @opts  = opts
        @input = opts[:input]
        @state = opts[:state]
      end
     
      def twiml
        @twiml ||= ::Twilio::TwiML::Response.new do |r|
        end
      end

    end
  end
end
