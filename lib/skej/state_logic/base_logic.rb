module Skej
  module StateLogic
    class BaseLogic

      include Skej::Endpoint

      # Container for debug messages,
      # which are later automatically fed to the TwiML view.
      @debug = []

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

        # Apply state logic and rules— stored and primed in this instance.
        # This ensures all instance variables are setup and defined for the
        # view functions to utilize.
        thinker unless @thinked.present?

        # Mark this instance as having thinked already.
        # We will use this at various points to ensure this instance
        # has been processed.
        @thinked = true
      end

      # For the current executing state, render some TwiML xml.
      # This is usually requested by the controller via the Session entity.
      #
      # The Session will then delegate the rendering of TwiML to the currently
      # active Logic module. The current logic module is defined by the current_state
      # string, which is transformed into a concrete class, then instantiated.
      #
      # One way or another, at the end of a Customer request, this method is called
      # to generate the final response for the request(s).
      def render

        # Since thinking is handed differently for a sub statemachine loop,
        # we exclude sub statemachine logic modules from this check.
        if @thinked.nil? and not is_sub_logic?

          # For some reason this module has not think'ed yet.
          #
          # So instead of calling it directly and messing up potential state,
          # we will simply initiate a redirect request (HTTP from Twilio) back to us
          # for additional processing.
          log 'redirecting back to the same state — to force a logic reflow'
          binding.pry

          twiml do |b|
            b.Redirect endpoint
          end
        end

        # We have already think'ed,
        # so let's deliver whatever payload thinking provided us with.
        twiml_payload
      end

      # Ensure we always thinked first, before attempting something...
      #
      # This is normally not needed, as thinking is handled automatically.
      #
      # However there are edge cases which it make it possible that this was not
      # thinked, due to being a new instance in memory.
      #
      # Thus there may be edgecases surrounding logic instance creation.
      #
      # However since the think process should be idopotent,
      # and able to be called repeatedly without side effects.
      #
      def think_first
        process! unless @thinked.present?
      end

      private

      # Determines if the current logic instance (self) is a sub module.
      # This is implied by using a sub namespace, ie. Skej::StateLogic::Appointments
      def is_sub_logic?
        self.class.name.underscore.include? "/appointments/"
      end

      # Determines if the customer has input present for the
      # current state phase.
      def user_input?
        params[:Body] || params[:Digits]
      end

      # Clears all session input for the current request
      #
      # Note: the customer input for a request is never actually
      # saved into the session.
      #
      # We clear multiple values, just to be safe.
      def clear_input!
        params[:Body] = nil
        params[:Digits] = nil
        @session.input[:Body] = nil if @session.input.present?
        @session.input[:Digits] = nil if @session.input.present?
        @session.clear_session_input!
      end

      # Provide access to this requests current request params.
      #
      # Note: All requests will pin the SystemLog and request
      # Params hash to the RequestStore.store abstraction around
      # Thread local.
      def params
        RequestStore.store[:params]
      end

      # Returns the textual time_zone offset for the Office
      # chosen for this session.
      #
      # We assume there is no reason the office won't be available.
      # Due to automatic assumptions, and requiring at least one office
      # per business.
      def time_zone
        @session.chosen_office.time_zone if @session.chosen_office.present?
      end

      # Delegate to session office
      def time_zone_offset
        @session.chosen_office.time_zone_offset
      end

      # For the current Business on this Session,
      # we can lookup a *key setting for this Business.
      #
      # All settings are stored as a Setting model, which belongs_to
      # a Business.
      #
      # This provides simple settings lookup, while also caching lookups.
      #
      # Returns instance of Setting
      def setting(key)
        @setting_cache ||= {}
        return @setting_cache[key] if @setting_cache[key].present?

        log "looking up business setting: <strong>#{key}</strong>"
        setting = Setting.business(business).key(key).first
        raise "Unknown Setting key:#{key}" if setting.nil?

        @setting_cache[key] = setting
        setting
      end

      # Memoized business cache
      # As .business hits the activerecord interface on the Session model
      #
      def business
        @business ||= @session.business
      end

      # Gives you the current state name in key form.
      # The state key is able to be specified directly in the Logic sub class,
      # however it is recommended to use the auto generated name (see below) of the
      # Logic sub class name.
      #
      # eg.
      #
      # class Handshake < BaseLogic
      # returns :handshake
      #
      # class InitialDecoder < BaseLogic
      # return :initial_decoder
      #
      def state
        module_name = self.class.name.underscore.gsub!('skej/state_logic/','')
        @STATE_KEY ||= module_name.to_sym
      end

      # Produces the correct settings key fir the current assumption context.
      # Based on the underscore'd class name string, we either use the Office or Service keys.
      #
      # This can be expanded in the future to support more types of selections
      # which have assumption capabilities.
      #
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

      # Based on business rules, can we assume a selection?
      #
      # Note: the specific selection we are checking to assume
      # is a dynamic key (look at #assume_key)
      #
      # Which is either office or service selections.
      #
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

      # Based on business rules, can we assume a selection with the
      # ability to change that selection?
      #
      # Note: the specific selection we are checking to assume
      # is a dynamic key (look at #assume_key)
      #
      # Which is either office or service selections.
      #
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

      # Let's us know if we moved states in this particular request.
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
        if is_sub_logic?
          log "processing business sublogic for: #{appointment_session.current_state}"
        else
          log "processing business logic for: #{scheduler_session.current_state}"
        end

        think
      end

      # Produce a Twiml text payload.
      # Called only by the above process! method
      def twiml_payload
        @twiml_payload ||= false

        if @twiml_payload.present?
          log "returning cached twiml_payload"
          return @twiml_payload
        end

        # Ensure this specific instance in memory has already been processed
        # at least once to ensure the proper view headers are set.
        think_first

        log "processing twiml payload: #{@session}"

        if self.respond_to? :sms_and_voice
          # Provide a convient method to handle both sms and voice
          # requests.
          t = sms_and_voice
        else

          # Make the dispatch call to the correct method
          # (using mapped device terminology for the call convention)
          t = self.send @device.to_s
        end


        # stash the tiwml response on the session instance for controller pick up
        @session.twiml = t
        @twiml_payload = t

        # Make sure that we actually return the TwiML response xml builder here.
        # So we don't break any method chains relying on this xml response.
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
      def factory_twiml_block(meth, *args)
        if meth =~ /twiml_appointments_/
          klass = meth.to_s.gsub("twiml_appointments_", "skej/twiml/appointments/").classify
        else
          klass = meth.to_s.gsub("twiml_", "skej/twiml/").classify
        end

        # Make the string representation a real Class object.
        klass = klass.constantize

        # Prepare view local variables
        data = { device: @device, session: @session, debug: generate_debug_formatted_message }
        if args.length > 0 and args[0].kind_of? Hash
          data.merge! args[0]
        end

        log "twiml_view_factory -> #{klass.name.underscore}"

        # Instantiate the new instance from the dynamic Klass
        # we generated earlier.
        instance = klass.new(data)

        # Return the TwiML view instance
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
            mark_state_complete!

            # Assign the Chosen office id to the Session meta store
            assign_chosen_id! @supportable.id

            # Since we utilized the input, we must clear
            clear_session_input!

            # Ensure any values changes in the instance store, are persisted to disk.
            # Todo: remove this, as it isn't needed.
            @session.update_meta_store!

            # ADVANCE
            advance!

          else
            @bad_selection = true
            log "Oops, selection(#{@digits}) was not matched to any available Option"
          end
        end
      end

      # Handle any model assumptions on selections (based on business settings).
      #
      # This is a generic method which dynamically processes the Customers input,
      # in relation to deciding and assumming various selections.
      #
      # For example, assumption for both Services and Offices happen here.
      # And can easily support more state assumptions.
      def process_assumptions

        # Obtain the fallback choice defined directly on the Setting key/value — via
        # the supportable relationship
        #
        # This is setup in the setting page, where we explcitily set an Entity as belonging
        # to the setting, along with the original setting value.
        #
        @supportable = setting(assume_key).supportable

        # Generate a specific error for this  sub class State if the @supportable model is not found.
        # This is because the @supportable model should always be present in this situation.
        raise "#{state.to_s.titleize} Target not found during the assumption process: #{assume_key}, business:#{@session.business.id}" unless @supportable.present?

        ##################################################################
        # Assumption SWITCH
        #
        # Business can assume and will offer change.
        # let the TwiML view blocks handle this switching
        #
        # Also check that the customer did not already asked to change
        # ie. lookup #{state}_customer_asked_to_change
        #
        if can_assume_and_change? and not get["#{state}_customer_asked_to_change"]

          # Process the Customers answer to whether or not they want to use the
          # Assumed values.
          if get["#{state}_confirming_assumption"]
            if customer_entered_yes?
              log 'customer entered yes: wished to change the default assumption'
              get["#{state}_customer_asked_to_change"] = true

            elsif customer_entered_no?
              log 'customer entered no: proceeding to the next state'
              get["#{state}_customer_asked_to_change"] = false
              assign_chosen_id! @supportable.id

              clear_input!

              # ADVANCE
              return advance!

            else
              log "customer entered unknown input: #{params[:Body] || params[:Digits]}"
              get["#{state}_customer_asked_to_change"] = true

              # Force a commit for this session changes
              @session.update_meta_store!
            end

          # Let's silently move the customer to the next state
          else

            # Catch retry attempts, and force selection.
            # Instead of silently assuming.
            if get["#{state}_retrying"].present?
              log "acknowledging the retry attempt"
              get["#{state}_retrying"] = false
              process_input

            # If we can silently assume / use the summary page,
            # we will move on immediately.
            elsif can_silently_assume?
              log "silently setting the Assumption model"
              # Also silently set the chosen model.
              assign_chosen_id! @supportable.id
              advance!

            # Otherwise run with the multi step assumption confirmation
            # (currently just for voice users)
            else
              get["#{state}_confirming_assumption"] = true
            end

          end


        ##################################################################
        # Assumption SWITCH
        #
        # The Customer has already stated the intent to change the given selection.
        # Thus in this situation we will process the Customer input.
        #
        elsif get["#{state}_customer_asked_to_change"]
          log "processing normal selection input"
          # run normal input processing for this state, to process the new selection.
          process_input

        ##################################################################
        # Assumption SWITCH
        #
        # Business is set to assume and will not ask the Customer to change it.
        else
          log "can_assume! without offering the Customer a choice"

          # Load up the dictatorship
          get["chosen_#{state}_id"] = @supportable.id
          get["#{state}_customer_asked_to_change"] = false
          clear_session_input!
          return advance!
        end

      end

      # Set an id for the chosen model.
      # The chosen model is determined at runtime based on which state
      # is currently executing.
      #
      # Current chosen models supported are Office & Service models.
      def assign_chosen_id!(id)
        log "Assigning chosen id: #{id}"
        selector = false
        klass = self.class.name.underscore

        if klass =~ /office/
          selector = "office"

        elsif klass =~ /service/
          selector = "service"

        else
          # Raise an exception if we havn't defined the selector.
          #
          # This is because there are currently no situations that I can
          # imagine that require setting a chosen_xxx_id, other than Services and Offices.
          #
          # Of course this could change in the future, if any additional states are added
          # that would utilize this method.
          raise "This method (assign_chosen_id) is not supported on anything else besides Office & Service logic modules" unless selector
        end

        @session.store! "chosen_#{selector}_id", id
      end

      # Memoize the query object based on this @session.
      def query
        @query ||= Skej::Appointments::Query.new(@session)
      end

      def session
        @session
      end

      def can_silently_assume?
        @session.sms?
      end

      def debug(str)
        @debug ||= []
        @debug << str
      end

      def generate_debug_formatted_message
        @debug ||= []

        # Optionally add some debug output
        return false if @debug.empty? or Rails.env.production?

        dbg = @debug.each_with_index { |d,i|
         @debug[i] = "#{i + 1} - #{d}"
        }.join('\n')

        message = "\n"
        #message << "-------------------\n"
        message << "DEBUG MESSAGES: \n"
        message << "#{dbg}\n"
        message << "-------------------\n\n"
        message
      end

      # Better named wrapper for the specific scheduler session
      def scheduler_session
        session
      end

      # Better named wrapper for the specific appointment session
      def appointment_session
        @session.appointment
      end

      # Automated method and recommended interface for marking the
      # state as complete.
      #
      # Thus allowing the state guards to let you pass.
      def mark_state_complete!
        get[state.to_s] = :complete
      end

      # Simple alias for the above method.
      # Note: We're in pure ruby here, no activesupport aliase helpers.
      def mark_as_completed!
        mark_state_complete!
      end

      # Determines if this current state is marked as complete?
      # Returns boolean.
      def marked_as_complete?
        get[state.to_s] and get[state.to_s].to_sym == :complete
      end

      # Strip a text string of everything except for integers
      def strip_to_int(input)
        return input unless input.present?
        return input if input[/[\d.,]+/].nil?

        input[/[\d.,]+/].gsub(',','.').to_i if input.present?
      end

      def method_missing(meth, *args, &block)
        if meth.to_s =~ /^twiml_(.+)$/ and meth.to_s != "twiml_payload"
          factory_twiml_block(meth.to_s, *args)
        else
          super
        end
      end

    end
  end
end
