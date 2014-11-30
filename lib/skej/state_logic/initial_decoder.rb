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
        log "sms session detected— engaging Chronic.parse(<strong>#{@session.input[:Body]}</strong>)"
        date = Chronic.parse(@session.input[:Body])

        if date
          log "date extracted: <strong>#{date}</strong>"
          @session.store! :message_date, date
          @session.clear_input_body!
        else
          log "no valid date detected: #{@session.input[:Body]}"
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

