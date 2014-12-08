module Skej
  module StateLogic
    class InitialDecoder < BaseLogic

      def think
        if @session.device_type.to_s.downcase.to_sym == :sms
          parse_date_and_store!
        else
          log "initial date decoding is not supported for: #{@session.device_type || 'unknown-device'}"
        end

        @session.store! :initial_decoder, :complete
        advance!
      end


      def parse_date_and_store!
        input = @session.input[:Body]

        log "sms session detected— engaging Chronic.parse(<strong>#{input}</strong>)"
        date = Chronic.parse(input)

        if date
          log "date extracted: <strong>#{date}</strong>"
          @session.store! :initial_date_input, input
          @session.clear_session_input!
        else
          log "no valid date detected: #{input}"
        end
      end

      def sms
        raise "InitialDecoder does not have a SMS response"
      end

      def voice
        raise "InitialDecoder does not have a VOICE response"
      end

    end
  end
end

