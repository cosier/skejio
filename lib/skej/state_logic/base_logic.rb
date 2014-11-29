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

      def payload
        if @@SKIP_PAYLOAD[self.class.name.underscore].nil?
          log "processing twiml payload"

          # Make the dispatch call to the correct method
          # (using mapped device terminology for the call convention)
          self.send(@device.to_s)

        else
          log "skipping twiml payload"
        end

        Rails.logger.info "Flushing Store to Session meta store"
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

      # Get a key value from the session store— notice the class name prefixing
      def get(key)
        @session.store["#{self.class.name.underscore}_#{key.to_s}"]
      end

      # Set a keyed value onto the session store— notice the class name prefixing
      def set(key, val)
        @session.store! "#{self.class.name.underscore}_#{key.to_s}", val
      end

      def store
        @store ||= (get(:store) || {})
      end
      # Flush the settings instance hash to the session meta store— json backing
      def flush_settings
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
          klass = meth.gsub("twiml_", "TwiML::").classify.constantize
          log "building_twiml_block: #{klass.name.underscore}"
          klass.new(args.first)
      end

      def method_missing(meth, *args, &block)
        if meth.to_s =~ /^twiml_(.+)$/
          build_twiml_block(meth, *args)
        else
          super
        end
      end

    end
  end
end
