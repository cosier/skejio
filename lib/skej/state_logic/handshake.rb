module Skej
  module StateLogic
    class Handshake < BaseLogic

      def think

        # Check if we have shaken hands yet?
        # OR if we are SMS— so we can be skipped.
        if @session.sms? || get[:handshake_shaked_hands].present?

          # Sets a property on the session that says
          # this state has completed
          mark_state_complete!

          # Advance to the next state, while ignoring the remaining
          # logic in this method.
          return advance!
        end

        # Shake their hand, and the next request will be passed
        # (see above condition)
        @session.store! :handshake_shaked_hands,  true

        # If we made it this far, the sms/voice handlers for this class
        # will be called.
        log "Preparing initial Welcome Handshake reply"

      end

      def sms
        twiml do |b|
          # Textual message
          #
          # Todo: Swappable per Business welcome text preferences.
          b.Message "Welcome to the Scheduler App"

          # Redirects the  Customer instantly back to our servers.
          #
          # This creates an additional http request from Twilio to Us,
          # thus allowing us to keep processing for this Customer without having
          # to wait for additional input.
          #
          # Since we are just stating a message, and not asking for input,
          # this redirection is important.
          b.Redirect endpoint
        end
      end

      def voice
        twiml do |b|
          # Voice TTS provided by Twilio
          #
          # Todo: Swappable per Business welcome recordings.
          b.Say "Welcome to the Scheduler App"

          # Redirects the  Customer instantly back to our servers.
          #
          # This creates an additional http request from Twilio to Us,
          # thus allowing us to keep processing for this Customer without having
          # to wait for additional input.
          #
          # Since we are just stating a message, and not asking for input,
          # this redirection is important.
          b.Redirect endpoint
        end
      end

    end
  end
end

