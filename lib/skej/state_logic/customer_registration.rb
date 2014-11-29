module Skej
  module StateLogic
    class CustomerRegistration < BaseLogic

      def think
        cust = @session.customer

        case @device.to_sym
        when :sms
          # If there is an available message body,
          # then we are assuming that is their name
          if @session.input[:Body].present?
            body = @session.input[:Body]
            log "received name from customer: #{body}"

            first_name = body.split(" ").first
            last_name = body.split(" ").last
            last_name = "" if last_name == first_name

            store[:customer_name] = body
            store[:customer_registration] = :complete

            @session.customer.update!({first_name: first_name, last_name: last_name})
          end

        when :voice
          # stash the customers recording
          recording_url = @session.input[:RecordingUrl]

          # Customer already has a name recording present
          if cust.recording_name_url.present?
            store[:customer_name] = cust.recording_name_url
          end

          # Check if the customer tried to record their name already
          if recording_url.present?
            log """
              received recording_url from the customer: <br/>
              <a href='#{recording_url}' target='_blank'>#{recording_url}</a>
            """

            store[:customer_name] = recording_url

            log "updating session customer with the new name recording"
            cust.update! :recording_name_url, recording_url
          end

        end

        binding.pry
        if store[:customer_name].present?
          # Update the session store with customer_registration as completed
          @session.store! :customer_registration, :complete
          # We're ready to go to the next transition
          @session.transition_next!
        end

      end

      def sms_and_voice
        twiml_ask_customer_name
      end

    end
  end
end

