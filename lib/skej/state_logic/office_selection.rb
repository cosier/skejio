module Skej
  module StateLogic
    class OfficeSelection < BaseLogic

      def think

        # Automatic pass, not enough offices to choose from.
        if @session.business.available_offices.length < 2
          get[:office_selection] = :complete
          return advance!
        end

      end

    end
  end
end

