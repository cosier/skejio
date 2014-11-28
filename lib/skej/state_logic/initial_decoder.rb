module Skej
  module StateLogic
    class InitialDecoder < BaseLogic

      def think
        log "thinking"

        if @session.device_type.to_s.downcase.to_sym == :sms
          parse_date_and_store!
        else
          log "initial date decoding is not supported for: #{@session.device_type || 'unknown-device'}"
        end
        
        log "saving state"

        @session.store! :initial_decoder, :complete
        @session.transition_next!
      end


      def parse_date_and_store!
        log "sms session detected— engaging Chronic.parse(<strong>#{@session.input[:Body]}</strong>)"
        date = Chronic.parse(@session.input[:Body])

        if date
          log "date extracted: <strong>#{date}</strong>"
          @session.store! :message_date, date
        else
          log "no valid date detected: #{@session.input[:Body]}"
        end
      end

    end
  end
end
