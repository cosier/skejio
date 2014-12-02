module Skej
  module StateLogic
    class Handshake < BaseLogic

      def think

        if get[:handshake_shaked_hands].present?
          @session.store! :handshake, :complete
          return advance!
        end

        # Shake their hand, and the next request will be passed
        # (see above condition)
        @session.store! :handshake_shaked_hands,  true

        log "Preparing initial Welcome Handshake reply"

      end

      def sms
        twiml do |b|
          b.Message "Welcome to the Scheduler App"
          b.Redirect endpoint
        end
      end

      def voice
        twiml do |b|
          b.Say "Welcome to the Scheduler App"
          b.Redirect endpoint
        end
      end

    end
  end
end

