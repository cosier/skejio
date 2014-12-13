module Skej
  module StateLogic
    class InitialDecoder < BaseLogic

      def think
        if @session.device_type.to_s.downcase.to_sym == :sms
          parse_date_and_store!
        else
          log "initial date decoding is not supported for: #{@session.device_type || 'unknown-device'}"
        end

        # Update the session store to mark this state as completed
        mark_as_completed!

        # Transition to the next state
        advance!
      end

      def sms_and_voice
        # Since this state ALWAYS advances on to the next state, regardless of Customer input.
        # This method should never be called, and is a bug in the dispatch chain if called.
        raise "InitialDecoder never produces a TwiML response for the Customer"
      end


      private

        # Take the Customer input and check if it is a valid date.
        # By means of natural language processing.
        #
        # If it is indeed a valid date, then we will store only the original
        # text for later transition into the correct date and timezone.
        #
        def parse_date_and_store!
          input = @session.input[:Body]

          log "sms session detected— engaging Chronic.parse(<strong>#{input}</strong>)"
          date = Chronic.parse(input)

          if date
            log "date extracted from initial message: <br/><strong>#{date}</strong>"

            # By using the #store! method directly, we are forcing a commit on this store transaction.
            @session.store! :initial_date_decoded, input

            # Ensure everythings cleaned up for the next state
            clear_input!

          else
            log "no valid date detected in the initial customer message: #{input}"
          end
        end

    end
  end
end

