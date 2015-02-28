module Skej
  module StateLogic
    class OfficeSelection < BaseLogic

      def think

        @offices = @session.business.available_offices.to_a
        @ordered = {}

        @offices.each_with_index do |office, index|
          @ordered[index + 1] = office
        end

        # Automatic pass, not enough offices to choose from.
        if @session.business.available_offices.length < 2
          log "Available Offices < 2 <br/><strong>Skipping Customer Selection of Offices</strong>"
          mark_state_complete!

          office = @session.business.available_offices.first
          @session.store! :chosen_office_id, office.id

          # ADVANCE
          return advance!
        end

        # Early bail out if already completed
        if marked_as_complete? and get[:chosen_office_id].present?
          log "Office selection already complete"
          # ADVANCE
          return advance!
        end

        binding.pry

        if can_assume?
          process_assumptions
        else
          # Process any input (digits or text body), and match it to the ordered collection
          process_input
        end

      end

      # Single method for both sms and voice
      def sms_and_voice

        # Reverse merge a default set of data,
        # which is based on top of the session store.
        #
        # Noticed session #get is mixed into the the hash.
        data = {
          offices: @ordered,
          default: @supportable,
          sanity: true
        }.reverse_merge!(get.symbolize_keys)

        # If we are asking for change, make sure the sub views
        # know that as well.
        if get[:office_selection_customer_asked_to_change].present?

          # We normalize the views usage of *ask* to a simple :ask key.
          # So it is more reusable across different situations.
          data[:ask] = true
        end

        # Return a twiml view, based on a condition.
        # Either repeat the selection, or ask normally (first time).
        if @bad_selection.present?
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

