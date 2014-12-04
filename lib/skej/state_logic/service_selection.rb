module Skej
  module StateLogic
    class ServiceSelection < BaseLogic

      def think
        @services = @session.business.available_services.to_a
        @ordered = {}

        @services.each_with_index do |service, index|
          @ordered[index + 1] = service
        end

        @digits = @session.input[:Digits] || strip_to_int(@session.input[:Body])

        # Early bail out if already completed
        if get[:service_selection].present? and get[:chosen_service_id].present?
          log "Service selection already complete"
          return advance!
        end

        # Automatic pass, not enough offices to choose from.
        if @services.length < 2
          log "Available Services < 2 <br/><strong>Skipping Customer Selection of Services</strong>"
          get[:service_selection] = :complete
          get[:chosen_service_id] = @services.first and @services.first.id
          return advance!
        end

        if can_assume?
          process_assumptions
        else
          # Process any input (digits or text body), and match it to the ordered collection
          process_input
        end

      end

      def sms_and_voice
        data = {
          services: @ordered,
          default: @supportable,
          sanity: true
        }.reverse_merge!(get.symbolize_keys)

        if get[:service_customer_asked_to_change].present?
          data[:ask] = true
        end

        if @bad_selection and @digits.present?
          # Show a sorry, incorrect input page and ask again
          twiml_repeat_service_selection(data)
        else
          # Just render normal menu selection
          twiml_ask_service_selection(data)
        end
      end

    end
  end
end

