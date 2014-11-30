module Skej
  module StateLogic
    class Retry < BaseLogic

      def think
        log "retrying #{@session.last_available_state}"
        @session.transition_to! @session.last_available_state
      end

    end
  end
end

