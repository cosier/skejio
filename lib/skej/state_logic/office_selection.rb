module Skej
  module StateLogic
    class OfficeSelection < BaseLogic

      def think

        # Automatic pass, not enough offices to choose from.
        if @session.business.available_offices.length < 2
          log "Available Offices < 2 <br/><strong>Skipping Customer Selection of Offices</strong>"
          get[:office_selection] = :complete
          return advance!
        end

      end

    end
  end
end

