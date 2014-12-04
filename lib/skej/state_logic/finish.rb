module Skej
  module StateLogic
    class Finish < BaseLogic

      state_key :finish

      def think
        log "Congratulations, we're Finished booking your next appointment!"
      end

      def sms
        twiml_final_report
      end

      def voice
        twiml_final_report
      end

    end
  end
end

