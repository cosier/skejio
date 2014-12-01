module Skej
  module StateLogic
    class ProviderSelection < BaseLogic

      def think

        # Automatic pass, not enough offices to choose from.
        if @session.business.available_providers.length < 2
          log "Available Providers < 2 <br/><strong>Skipping Customer Selection of Service Provider</strong>"
          get[:provider_selection] = :complete
          return advance!
        end

      end

      def sms
      end

      def voice
      end

    end
  end
end

