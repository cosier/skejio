module Skej
  module StateLogic
    module TwiML
      class BaseTwiML

        def initialize(opts = {})
          @opts = opts
          @data = opts[:data]
          @device = opts[:device]
        end

        def text
          @text ||= build_device_response
        end

        private

        # Dynamic device response type dispatch
        def build_device_response
          self.send "#{@device}", build_twiml
        end

        def build_twiml
          @twiml ||= Builder::XmlMarkup.new
        end

        # Log facilitator wrapper
        def log(msg)
          SystemLog.fact(title: self.class.name.underscore, payload: msg)
        end

      end
    end
  end
end

