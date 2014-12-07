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

        def state_key(key)
          # Deprecated
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
        @thinked = true
      end

      def render
        think_first
        twiml_payload
      end

      def think_first
        process! unless @thinked
      end

      private

      def user_input?
        params[:Body].present? || params[:Digits].present?
      end

      def clear_input!
        params[:Body] = nil
        params[:Digits] = nil
        @session.input[:Body] = nil if @session.input.present?
        @session.input[:Digits] = nil if @session.input.present?
      end

      def params
        RequestStore.store[:params]
      end

      def offset
        @session.chosen_office.time_zone
      end

      def setting(key)
        @setting_cache ||= {}
        return @setting_cache[key] if @setting_cache[key].present?

        log "looking up business setting: <strong>#{key}</strong>"
        setting = Setting.business(business).key(key).first
        raise "Unknown Setting key:#{key}" if setting.nil?

        @setting_cache[key] = setting
        setting
      end

      def business
        @business ||= @session.business
      end

      def state
        @STATE_KEY ||= self.class.name.underscore.gsub!('skej/state_logic/','').split('_').first.to_sym
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
          log "can assume(<strong>#{assume_key}</strong>)"
          @can_assume = true
          return true
        else
          log "can not assume(<strong>#{assume_key}</strong>)"
          return false
        end
      end

      def can_assume_and_change?
        if can_assume?

          # Cache wall first
          @can_assume_and_change ||= false
          return @can_assume_and_change if @can_assume_and_change.present?

          # Returns TRUE if the setting contains "assume"
          #
          # Lookup the available Setting constants for all the
          # various key mappings.
          if setting(assume_key).value =~ /_ask_and_assume/
            log "can assume(<strong>#{assume_key}</strong>) and <strong>change</strong>"
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
        @session.update_meta_store!

        log "advancing to the next transition"

        # Bail and log when we are dry run testing of a particular state
        if opts[:dry].present? and Rails.env.development?
          log "advance! -> dry run triggered"
          @advanced_state = true
          return
        end

        mark_state_complete!
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
        @session.input.delete :Digits if @session.input
        @session.input.delete :Body if @session.input
        params.delete :Digits if params
        params.delete :Body if params
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
        if meth =~ /twiml_appointments_/
          klass = meth.to_s.gsub("twiml_appointments_", "skej/twiml/appointments/").classify
        else
          klass = meth.to_s.gsub("twiml_", "skej/twiml/").classify
        end

        # Make it real here
        klass = klass.constantize

        data = { device: @device, session: @session }
        if args.length > 0 and args[0].kind_of? Hash
          data.merge! args[0]
        end

        log "building_twiml_block: #{klass.name.underscore}"
        instance = klass.new(data)
        instance
      end

      def customer_entered_no?(defaults = {})
        customer_entered_yes?(voice: 2, sms: "n")
      end

      def customer_entered_yes?(defaults = {})
        defaults.reverse_merge! voice: 1, sms: "y"

        if params[:Body].present?
          # Does the sms input match our definition of yes?
          return params[:Body].include? defaults[:sms].to_s

        elsif params[:Digits].present?
          # Does the voice input match our definition of yes?
          return  params[:Digits].to_i == defaults[:voice].to_i
        end

        # Does not look like the customer confirmed the action
        return false
      end

      # Handle Customer Input — advancement logic
      def process_input
        @digits = params[:Digits] || strip_to_int(params[:Body])

        # Attempt processing of the digits
        if @digits.present?
          log "Processing Customer Input Digits: <strong>#{@digits}</strong>"

          if @supportable = @ordered[@digits.to_i]
            log "Customer has Selected #{state.to_s.titleize}: <strong>#{@supportable.display_name}</strong>"

            # Mark the state as complete— allowing the Guards to pass us
            get["#{state}_selection"] = :complete

            # Assign the Chosen office id to the Session meta store
            get["chosen_#{state}_id"] = @supportable.id

            # Since we utilized the input, we must clear
            clear_session_input!
            @session.update_meta_store!

            # ADVANCE
            advance!

          else
            @bad_selection = true
            log "Oops, selection(#{@digits}) was not matched to any available Office"
          end
        end
      end

      # Handle any model assumptions on selections (based on business settings)
      def process_assumptions

        # Obtain the office defined directly on the Setting key/value — via
        # the supportable relationship
        @supportable = setting(assume_key).supportable
        raise "#{state.to_s.titleize} Target not found during the assumption process: #{assume_key}, business:#{@session.business.id}" unless @supportable.present?

        ##################################################################
        # Business can assume and will offer change
        # let the TwiML view blocks handle this switching
        if can_assume_and_change? and not get["#{state}_customer_asked_to_change"]
          if get["#{state}_confirming_assumption"]
            if customer_entered_yes?
              log 'customer entered yes: wished to change the default assumption'
              get["#{state}_customer_asked_to_change"] = true

            elsif customer_entered_no?
              log 'customer entered no: proceeding to the next state'
              get["#{state}_customer_asked_to_change"] = false
              get["chosen_#{state}_id"] = @supportable.id

              clear_session_input!

              # ADVANCE
              return advance!

            else
              log "customer entered unknown input: #{params[:Body] || params[:Digits]}"
              get["#{state}_customer_asked_to_change"] = true
            end
          else
            log "attempting to ask the Customer for Assumption confirmation"
            get["#{state}_confirming_assumption"] = true
          end

          @session.update_meta_store!

        ##################################################################
        elsif get["#{state}_customer_asked_to_change"]
          log "processing normal selection input"
          # run normal input processing for this state, to process the new selection.
          process_input

        ##################################################################
        # Business is set to assume and will not ask the Customer to change it.
        else
          log "can_assume!"

          # Load up the dictatorship
          get["chosen_#{state}_id"] = @supportable.id
          get["#{state}_customer_asked_to_change"] = false
          clear_session_input!
          return advance!
        end
      end

      def mark_state_complete!
        get["#{state}_selection"] = :complete
        get["#{state}"] = :complete
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
