module Skej
  module StateLogic
    class ProviderSelection < BaseLogic

      @@STATE_KEY = :provider

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
        if get[:provider_selection] and get[:provider_selection].to_sym == :complete
          log "Provider selection already complete"
          advance!
        end

        # Automatic pass— not enough providers to choose from.
        if @providers.length < 2
          log "Available Providers < 2 <br/><strong>Skipping Customer Selection of Providers</strong>"
          get[:provider_selection] = :complete
          # Choose the only available provider for this business
          get[:chosen_provider_id] = @providers.first and @providers.first.id
          return advance!
        end

        # Attempt processing of the digits
        if @digits.present?
          log "Processing Customer Input Digits: <strong>#{@digits}</strong>"

          if @chosen_provider = @providers_ordered[@digits.to_i]
            log "Customer has Selected Provider: <strong>#{@chosen_provider.display_name}</strong>"

            get[:provider_selection] = :complete
            get[:chosen_provider_id] = @chosen_provider.id

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
        if @bad_selection and @digits.present?
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

