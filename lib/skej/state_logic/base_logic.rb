module Skej
  module StateLogic
    class BaseLogic
      
      def initialize(opts)
        @opts = opts
        @device = opts[:device]
        @session = opts[:session]
      end

      def process!
        think

        case @device.to_sym
        when :sms
          payload = voice
        when :voice
          payload = sms
        else
          raise "Unknown device type: #{@device}"
        end

        payload
      end

      def think
        SystemLog.fact(title: self.class.name.underscore, payload: "process(#{@session.display_name}) not implemented")
      end

      def sms
        ::Twilio::TwiML::Response.new do |r|
          r.Message "Welcome to #{@session.current_state.titleize}"
        end
      end

      def voice
        ::Twilio::TwiML::Response.new do |r|
          r.Say "Welcome to #{@session.current_state.titleize}"
        end
      end

      private

      def log(msg)
        SystemLog.fact(title: self.class.name.underscore, payload: msg)
      end

    end
  end
end
