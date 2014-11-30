module Skej
  module StateLogic
    class OfficeSelection < BaseLogic

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
          return advance!
        end

        @digits = @session.input[:Digits] || strip_to_int(@session.input[:Body])

        # Early bail out if already completed
        if get[:office_selection] and get[:office_selection].to_sym == :complete
          log "Office selection already complete"
          advance!
        end

        # Attempt processing of the digits
        if @digits.present?
          log "Processing Customer Input Digits: <strong>#{@digits}</strong>"

          if @chosen_office = @offices_ordered[@digits.to_i]
            log "Customer has Selected Office: <strong>#{@chosen_office.display_name}</strong>"

            get[:office_selection] = :complete
            get[:chosen_office_id] = @chosen_office.id

            # Since we utilized the input, we must clear
            clear_session_input!
            advance!
          else
            @bad_selection = true
            log "Available Offices: <br/>#{@human_readable_offices.to_json}"
            log "Oops, selection(#{@digits}) was not matched to any available Office"
          end
        end

      end

      def sms_and_voice
        if @bad_selection and @digits.present?
          # Show a sorry, incorrect input page and ask again
          twiml_repeat_office_selection offices: @offices_ordered
        else
          # Just render normal menu selection
          twiml_ask_office_selection offices: @offices_ordered
        end
      end

    end
  end
end

