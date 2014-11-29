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
        @device = opts[:device].to_sym
        @session = opts[:session]
      end

      def process!
        thinker
        payload
      end

      # Proce a Twiml text payload
      def payload
        p = false

        if @@SKIP_PAYLOAD[self.class.name.underscore].nil?
          log "processing twiml payload"

          if defined? self.sms_and_voice
            p = sms_and_voice
          else
            # Make the dispatch call to the correct method
            # (using mapped device terminology for the call convention)
            p = self.send(@device.to_s, twiml, @session)
          end

        else
          log "skipping twiml payload"
        end

        # Make sure that we actually return the TwiML response xml builder here
        p
      end

      # Parent wrapper around the subclass definition
      # to provide logging and skipping facilities on the *think* method
      def thinker
        if @@DONT_THINK[self.class.name.underscore].nil?
          log "processing business logic"
          think

          # Once thinking tick is done,
          # flush the settings to the backing session store (json)
          flush_settings
        else
          log "skipping business logic"
        end
      end

      # Default think step place holder
      # Override this in the sub logic
      def think
        SystemLog.fact(title: self.class.name.underscore, payload: "process(#{@session.display_name}) not implemented")
      end

      # Default SMS implementation message
      # Override this in the sub logic
      def sms
        twiml do |r|
          r.Message "Welcome to #{@session.current_state.titleize}"
        end
      end

      # Default VOICE implementation message
      # Override this in the sub logic
      def voice
        twiml do |r|
          r.Say "Welcome to #{@session.current_state.titleize}"
        end
      end

      private

      # Get a key value from the session store— notice the class name prefixing
      def get(key)
        @session.store[key]
      end

      # Set a keyed value onto the session store— notice the class name prefixing
      def set(key, val)
        @session.store! "#{key.to_s}", val
      end

      def store
        @store ||= (get(:store) || {})
      end

      # Flush the settings instance hash to the session meta store— json backing
      def flush_settings
        msg = "Flushing Logic Store to Session meta store — json backed"
        Rails.logger.info msg
        log(msg)
        set :store, store
      end

      # TwiML Response generator helper / wrapper
      def twiml(&block)
        log "processing twiml block"

        response = ::Twilio::TwiML::Response.new do |r|
          block.call(r)
        end

        response
      end

      # Handy wrapper around the Fact logging facility
      def log(msg)
        SystemLog.fact(title: self.class.name.underscore, payload: msg)
      end

      def build_twiml_block(meth, *args)
        klass = meth.to_s.gsub("twiml_", "skej/twiml/").classify
        klass = klass.constantize

        log "building_twiml_block: #{klass.name.underscore}"
        instance = klass.new({ device: @device, session: @session })
        instance
      end

      def method_missing(meth, *args, &block)
        if meth.to_s =~ /^twiml_(.+)$/
          build_twiml_block(meth.to_s, *args)
        else
          super
        end
      end

    end
  end
end
