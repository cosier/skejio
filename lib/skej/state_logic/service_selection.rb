module Skej
  module StateLogic
    class ServiceSelection < BaseLogic

      @@STATE_KEY = :service

      def think
        @services = @session.business.available_services.to_a
        @services_ordered = {}
        @human_readable_services = []

        @services.each_with_index do |service, index|
          @services_ordered[index + 1] = service
          @human_readable_services << "#{index + 1} - #{service.name}"
        end

        @digits = @session.input[:Digits] || strip_to_int(@session.input[:Body])

        # Early bail out if already completed
        if get[:service_selection] and get[:service_selection].to_sym == :complete
          log "Service selection already complete"
          advance!
        end

        # Automatic pass, not enough offices to choose from.
        if @services.length < 2
          log "Available Services < 2 <br/><strong>Skipping Customer Selection of Services</strong>"
          get[:service_selection] = :complete
          get[:chosen_service_id] = @services.first and @services.first.id
          return advance!
        end

        # Attempt processing of the digits
        if @digits.present?
          log "Processing Customer Input Digits: <strong>#{@digits}</strong>"

          if @chosen_service = @services_ordered[@digits.to_i]
            log "Customer has Selected Service: <strong>#{@chosen_service.display_name}</strong>"

            get[:service_selection] = :complete
            get[:chosen_service_id] = @chosen_service.id

            # Since we utilized the input, we must clear
            clear_session_input!
            advance!
          else
            @bad_selection = true
            log "Available Services: <br/>#{@human_readable_services.to_json}"
            log "Oops, selection(#{@digits}) was not matched to any available Service"
          end
        end

      end

      def sms_and_voice
        if @bad_selection and @digits.present?
          # Show a sorry, incorrect input page and ask again
          twiml_repeat_service_selection services: @services_ordered
        else
          # Just render normal menu selection
          twiml_ask_service_selection services: @services_ordered
        end
      end

    end
  end
end

