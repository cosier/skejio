module Skej
  module StateLogic
    class ProviderSelection < BaseLogic

      def think

        @providers = @session.business.available_providers.to_a
        @providers_ordered = {}
        @human_readable_providers = []

        @providers.each_with_index do |provider, index|
          @providers_ordered[index + 1] = provider
          @human_readable_providers << "#{index + 1} - #{provider.display_name}"
        end

        # Normalise all device input from the Customer
        @digits = @session.input[:Digits] || strip_to_int(@session.input[:Body])

        # Early bail out if already completed
        if marked_as_complete?
          log "Provider selection already complete"

          # Transition to the next state
          advance!
        end

        # Automatic pass— not enough providers to choose from.
        if @providers.length < 2
          log "Available Providers < 2 <br/><strong>Skipping Customer Selection of Providers</strong>"

          # Update the session store to mark this state as :complete
          mark_as_completed!

          # Choose the only available provider for this business
          get[:chosen_provider_id] = (@providers.first and @providers.first.id)

          return advance!
        end


        unless setting(:user_selection).user_selection_full_control?
          log "Business setting for User_Selection is <strong>not FULL_CONTROL</strong>— skipping explicit provider selection"
          get[:chosen_provider_id] = :deferred

          mark_as_completed! and advance!
          return
        end

        # Attempt processing of the digits
        if @digits.present?
          log "Processing Customer Input Digits: <strong>#{@digits}</strong>"

          if @chosen_provider = @providers_ordered[@digits.to_i]
            log "Customer has Selected Provider: <strong>#{@chosen_provider.display_name}</strong>"

            get[:chosen_provider_id] = @chosen_provider.id

            # Update the session store to mark this state as :complete
            mark_as_completed!


            # Since we utilized the input, we must clear
            clear_session_input!
            advance!

          else
            @bad_selection = true
            log "Available Providers: <br/>#{@human_readable_providers.to_json}"
            log "Oops, selection(#{@digits}) was not matched to any available Provider"
          end
        end

      end

      def sms_and_voice
        if @bad_selection.present?
          # Show a sorry, incorrect input page and ask again
          twiml_repeat_provider_selection providers: @providers_ordered
        else
          # Just render normal menu selection
          twiml_ask_provider_selection providers: @providers_ordered
        end
      end
    end

  end
end

