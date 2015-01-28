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
        if marked_as_complete? and get[:chosen_service_id].present?
          log "Service selection already complete"
          return advance!
        end

        # Automatic pass, not enough offices to choose from.
        if @services.length < 2
          log "Available Services < 2 <br/><strong>Skipping Customer Selection of Services</strong>"

          get[:chosen_service_id] = (@services.first and @services.first.id)

          # Mark completed and go to the next transition
          mark_as_completed! and advance!

          # Early bail out
          return

        end

        # We either process assumptions, or process Customer input directly.
        # Assumptions is based on Business settings.
        if can_assume?
          process_assumptions

        else
          # Process any input (digits or text body), and match it to the ordered collection
          # that we build at the top of this method.
          process_input
        end

      end

      # Combination method for handling both SMS and Voice dispatches.
      # Since we delegate to the sub view, and let that view handle the sms/voice branching.
      def sms_and_voice

        # Mix in session store data for View locals
        view_locals = {
          services: @ordered,
          default: @supportable,
          sanity: true
        }.reverse_merge!(get.symbolize_keys)

        # Normalising :service...asking key to just :ask
        if get[:service_selection_customer_asked_to_change].present?
          view_locals[:ask] = true
        end

        if @bad_selection.present?
          # Show a sorry, incorrect input page and ask again
          twiml_repeat_service_selection(view_locals)
        else
          # Just render normal menu selection
          twiml_ask_service_selection(view_locals)
        end

      end

    end
  end
end

