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
        target_method = self.class.instance_method(@device)

        # If the target_method takes at least 1 argument,
        # then send the session object as well.
        #
        # Otherwise don't send the session.
        #
        # This let's the view decide if it needs the session or not.
        #
        # Thus for views without the need for explicit session access,
        # they can exclude the method signature— for cleanliness and isolation.
        if target_method.arity >= 1
          response = self.send @device, @opts[:session]
        else
          response = self.send @device
        end

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

