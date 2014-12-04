module Skej
  module StateLogic
    class OfficeSelection < BaseLogic

      # Toggle this to true for debugging purposes,
      # which disables advancement to the next state— allowing tight testing
      state_key :office

      def think

        @offices = @session.business.available_offices.to_a
        @offices_ordered = {}
        @human_readable_offices = []

        @offices.each_with_index do |office, index|
          @offices_ordered[index + 1] = office
          @human_readable_offices << "#{index + 1} - #{office.name}"
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

      # Handle Customer Input — advancement logic
      def process_input
        @digits = @session.input[:Digits] || strip_to_int(@session.input[:Body])

        # Attempt processing of the digits
        if @digits.present?
          log "Processing Customer Input Digits: <strong>#{@digits}</strong>"

          if @chosen_office = @offices_ordered[@digits.to_i]
            log "Customer has Selected Office: <strong>#{@chosen_office.display_name}</strong>"

            # Mark the state as complete— allowing the Guards to pass us
            get[:office_selection] = :complete

            # Assign the Chosen office id to the Session meta store
            get[:chosen_office_id] = @chosen_office.id

            # Since we utilized the input, we must clear
            clear_session_input!

            # ADVANCE
            advance!

          else
            @bad_selection = true
            log "Available Offices: <br/>#{@human_readable_offices.to_json}"
            log "Oops, selection(#{@digits}) was not matched to any available Office"
          end
        end
      end

      def sms_and_voice
        data = {
          offices: @offices_ordered,
          default: @chosen_office || @supportable,
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

