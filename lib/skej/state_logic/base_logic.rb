module Skej
  module StateLogic
    class BaseLogic

      @@SKIP_PAYLOAD = {}
      @@DONT_THINK = {}

      # ::BaseLogic Class methods
      class << self

        # Identifies the sub class as "skippable"
        # for TwiML Payload Generation   (skip_payload)
        def skip_payload
          @@SKIP_PAYLOAD[self.name.underscore] = true
        end

        # Identifies the sub class as "skippable"
        # for Behaviour Processing (dont_think)
        def dont_think
          @@DONT_THINK[self.name.underscore] = true
        end

      end

      def initialize(opts)
        @opts = opts
        @device = opts[:device].to_sym
        @session = opts[:session]
      end

      # Thinks, then returns the payload
      # payload in this case is a Skej::Twiml::BaseTwiml instance.
      def process!
        # Apply state logic and rules
        thinker
      end

      def render
        twiml_payload
      end

      private

      def advanced_state?
        @advanced_state.present?
      end

      # Move the Session forward to the next level / state
      def advance!
        log "advancing to the next transition"
        @advanced_state = @session.state.transition_next!
      end

      def endpoint(data = {})
        data.reverse_merge! :log_id => SystemLog.current_log.id, method: 'get', sub_request: 'true'
        url = "#{ENV['PROTOCOL'].downcase}://#{ENV['HOST']}/twilio/#{data[:device] || @device}"
        url << "?#{data.to_query.html_safe}" if data.keys.length > 0
        url.html_safe
      end


      # If you utilize the customer input to perform a permenanent side effect,
      # then make sure you clear the session input for the next state to behave correctly.
      #
      # As the next state may happen instantaneously, and not between http requests—
      # thus session input must be handled carefully from state to state, as not to get
      # contaminated.
      def clear_session_input!
        log "clearing session input to avoid state contamination"
        @session.input.delete :Digits
        @session.input.delete :Body
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

      # Produce a Twiml text payload.
      # Called only by the above process! method
      def twiml_payload
        @twiml_payload ||= false

        if @twiml_payload.present?
          log "returning cached twiml_payload"
          return @twiml_payload
        end

        if @@SKIP_PAYLOAD[self.class.name.underscore].nil?
          log "processing twiml payload"
          if self.respond_to? :sms_and_voice
            t = sms_and_voice
          else
            # Make the dispatch call to the correct method
            # (using mapped device terminology for the call convention)
            t = self.send @device.to_s
          end

        else
          log "skipping twiml payload"
        end

        # stash the tiwml response on the session instance for controller pick up
        @session.twiml = t
        @twiml_payload = t

        # Make sure that we actually return the TwiML response xml builder here
        t
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
          r.Message "Welcome to #{@session.current_state.titleize}, this area is currently under construction. \nPlease check back soon"
          r.Pause length: 2
        end
      end

      # Default VOICE implementation message
      # Override this in the sub logic
      def voice
        twiml do |r|
          r.Say "Welcome to #{@session.current_state.titleize}... This area is currently under construction."
          r.Pause length: 2
          r.Say "Have a nice day"
        end
      end

      # Get a key value from the session store— notice the class name prefixing
      def get
        @session.store
      end

      # Set a keyed value onto the session store— notice the class name prefixing
      def set(key, val)
        @session.store! "#{key.to_s}", val
      end

      # TwiML Response generator helper / wrapper
      def twiml(&block)
        log "processing twiml block"

        response = ::Twilio::TwiML::Response.new do |r|
          block.call(r) if block_given?
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

        data = { device: @device, session: @session }
        if args.length > 0 and args[0].kind_of? Hash
          data.merge! args[0]
        end

        log "building_twiml_block: #{klass.name.underscore}"
        instance = klass.new(data)
        instance
      end

      def strip_to_int(input)
        return input unless input.present?
        return input if input[/[\d.,]+/].nil?

        input[/[\d.,]+/].gsub(',','.').to_i if input.present?
      end

      def method_missing(meth, *args, &block)
        if meth.to_s =~ /^twiml_(.+)$/ and meth.to_s != "twiml_payload"
          build_twiml_block(meth.to_s, *args)
        else
          super
        end
      end

    end
  end
end
