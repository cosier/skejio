module Skej
  module StateLogic
    class CustomerRegistration < BaseLogic


      def think
        cust = @session.customer

        # Processing customer input as their name,
        # unless they already have a name
        process_name unless cust.has_name?

        if get[:customer_name].present? || cust.has_name?
          # Update the session get with customer_registration as completed
          get[:customer_registration] = :complete

          # We're ready to go to the next transition
          advance!
        else

          # We do nothing else, and let the twiml views for this state_logic
          # carry the Customer to the next step.
        end

      end

      def sms
        log "SMS — asking for customer name"
        twiml_ask_customer_name
      end

      def voice
        log "VOICE — asking for customer name"
        twiml_ask_customer_name
      end


      private

      def process_name
        case @device.to_sym

        ##################################################
        # We are processing a SMS Session
        when :sms
          # If there is an available message body,
          # then we are assuming that is their name
          if @session.input[:Body].present?
            body = @session.input[:Body]
            log "received name from customer: #{body}"

            first_name = body.split(" ").first
            last_name = body.split(" ").last
            last_name = "" if last_name == first_name

            get[:customer_name] = body
            get[:customer_registration] = :complete

            @session.customer.update!({first_name: first_name, last_name: last_name})
          end

        ##################################################
        # We are processing a VOICE Session
        when :voice
          # stash the customers recording
          recording_url = @session.input[:RecordingUrl]

          # Customer already has a name recording present
          if cust.recording_name_url.present?
            get[:customer_name] = cust.recording_name_url
          end

          # Check if the customer tried to record their name already
          if recording_url.present?
            log """
              received recording_url from the customer: <br/>
              <a href='#{recording_url}' target='_blank'>#{recording_url}</a>
            """

            get[:customer_name] = recording_url

            log "updating session customer with the new name recording"
            cust.update! :recording_name_url, recording_url
          end

        end
      end

    end
  end
end

