module Skej
  module StateLogic
    class BaseLogic

      include Skej::Endpoint

      @@SKIP_PAYLOAD = {}
      @@DONT_THINK = {}
      @@DRY_RUN = false

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

      # Initializes the class with a device type and the active Session
      def initialize(opts)
        @device = opts[:device].to_sym
        @session = opts[:session]

        # Stash original opts for inspection purposes
        @opts = opts
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

      def setting(key)
        log "looking up business setting: <strong>#{key}</strong>"
        setting = Setting.business(business).key(key).first
        raise "Unknown Setting key:#{key}" if setting.nil?
        setting
      end

      def business
        @business ||= @session.business
      end

      def assume_key
        # Determine the correct key we need to check.
        # We have only two potential values here, see usage below.
        #
        # Check if the class name (underscore'd) contains "office"
        if self.class.name.underscore =~ /office/
          key = Setting::OFFICE_SELECTION
        else
          key = Setting::SERVICE_SELECTION
        end
      end

      def can_assume?
        # Cache wall first
        @can_assume ||= false
        return true if @can_assume.present?

        # Lookup the available Setting constants for all the
        # various key mappings.
        #
        # Returns TRUE if the setting contains "assume"
        if setting(assume_key).value =~ /_assume/
          log "can assume(<strong>#{key}</strong>)"
          @can_assume = true
          return true
        else
          log "can not assume(<strong>#{key}</strong>)"
          return false
        end
      end

      def can_assume_and_change?
        if can_assume?

          # Cache wall first
          @can_assume_and_change ||= false
          return @can_assume_and_change if @can_assume_and_change.present?

          if self.class.name.underscore =~ /office/
            key = Setting::OFFICE_SELECTION
          else
            key = Setting::SERVICE_SELECTION
          end

          # Returns TRUE if the setting contains "assume"
          #
          # Lookup the available Setting constants for all the
          # various key mappings.
          if setting(key) =~ /_ask_and_assume/
            @can_assume_and_change = true
            return true
          end

        end
      end

      def advanced_state?
        @advanced_state.present?
      end

      # Move the Session forward to the next level / state
      def advance!(opts = {})
        log "advancing to the next transition"

        # Bail and log when we are dry run testing of a particular state
        if opts[:dry].present? and Rails.env.development?
          log "advance! -> dry run triggered"
          @advanced_state = true
          return
        end

        @advanced_state = @session.state.transition_next!
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

      # Factory for building SKej::TwiML view blocks for deferred rendering
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

      # Strip a text string of everything except for integers
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
