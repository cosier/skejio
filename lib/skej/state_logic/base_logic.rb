module Skej
  module StateLogic
    class BaseLogic
      
      @@SKIP_PAYLOAD = {}
      @@DONT_THINK = {}

      class << self
        def skip_payload
          @@SKIP_PAYLOAD[self.name.underscore] = true
        end

        def dont_think
          @@DONT_THINK[self.name.underscore] = true
        end
      end

      def initialize(opts)
        @opts = opts
        @device = opts[:device]
        @session = opts[:session]
      end

      def process!
        thinker
        payload
      end

      def payload
        if @@SKIP_PAYLOAD[self.class.name.underscore].nil?
          log "processing twiml payload"

          # Make the dispatch call to the correct method
          # (using mapped device terminology for the call convention)
          self.send(@device.to_s) 
        else
          log "skipping twiml payload"
        end
      end

      # Parent wrapper around the subclass definition
      # to provide logging and skipping facilities on the *think* method
      def thinker
        if @@DONT_THINK[self.class.name.underscore].nil?
          log "processing business logic"
          think
        else
          log "skipping business logic"
        end
      end

      def think
        SystemLog.fact(title: self.class.name.underscore, payload: "process(#{@session.display_name}) not implemented")
      end

      def sms
        twiml do |r|
          r.Message "Welcome to #{@session.current_state.titleize}"
        end
      end

      def voice
        twiml do |r|
          r.Say "Welcome to #{@session.current_state.titleize}"
        end
      end

      private
      
      def twiml(&block)
        ::Twilio::TwiML::Response.new(&:block)
      end

      def log(msg)
        SystemLog.fact(title: self.class.name.underscore, payload: msg)
      end

    end
  end
end
