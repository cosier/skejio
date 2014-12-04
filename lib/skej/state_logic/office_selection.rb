module Skej
  module StateLogic
    class OfficeSelection < BaseLogic

      # Toggle this to true for debugging purposes,
      # which disables advancement to the next state— allowing tight testing
      state_key :office

      def think

        @offices = @session.business.available_offices.to_a
        @ordered = {}

        @offices.each_with_index do |office, index|
          @ordered[index + 1] = office
        end

        # Automatic pass, not enough offices to choose from.
        if @session.business.available_offices.length < 2
          log "Available Offices < 2 <br/><strong>Skipping Customer Selection of Offices</strong>"
          get[:office_selection] = :complete

          # ADVANCE
          return advance!
        end

        # Early bail out if already completed
        if get[:office_selection].present? and get[:chosen_office_id].present?
          log "Office selection already complete"
          # ADVANCE
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
          offices: @ordered,
          default: @supportable || @supportable,
          sanity: true
        }.reverse_merge!(get.symbolize_keys)

        if get[:office_customer_asked_to_change].present?
          data[:ask] = true
        end

        if @bad_selection and @digits.present?
          # Show a sorry, incorrect input page and ask again
          twiml_repeat_office_selection(data)
        else
          # Just render normal menu selection
          twiml_ask_office_selection(data)
        end
      end

    end
  end
end

