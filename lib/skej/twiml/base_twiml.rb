module Skej
  module Twiml
    class BaseTwiml

      include Skej::Endpoint

      def initialize(opts = {})
        @opts = opts
        @data = opts[:data]
        @device = opts[:device]
      end

      def text
        @text ||= build_device_response.text
      end

      private

      def options
        @opts
      end

      # Dynamic device response type dispatch
      def build_device_response
        response = self.send "#{@device}", @opts[:session]
        response
      end

      def build_twiml(&block)
        ::Twilio::TwiML::Response.new do |b|
          block.call(b)
        end
      end

      # Log facilitator wrapper
      def log(msg)
        SystemLog.fact(title: self.class.name.underscore, payload: msg)
      end

    end
  end
end

