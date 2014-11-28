module Skej
  module StateLogic
    class InitialDecoder < BaseLogic

      def think
        if session.device_type == :sms
          log "sms session detected— engaging Chronic.parse(#{session.input[:Body]})"
          date = Chronic.parse(session.input[:Body])
          if date
            log "date extracted: #{date}"
            session.store! :message_date, date
          else
            log "no valid date detected: #{session.input[:Body]}"
          end
        else
          log "initial date decoding is not supported for: #{session.device_type || 'unknown-device'}"
        end

        session.store! :initial_decode, :complete
        session.transition_next!
      end

    end
  end
end

