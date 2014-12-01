module Skej
  module StateLogic
    class ServiceSelection < BaseLogic

      def think

        # Automatic pass, not enough offices to choose from.
        if @session.business.available_services.length < 2
          log "Available Services < 2 <br/><strong>Skipping Customer Selection of Services</strong>"
          get[:service_selection] = :complete
          return advance!
        end

      end

    end
  end
end

