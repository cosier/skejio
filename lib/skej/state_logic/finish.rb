module Skej
  module StateLogic
    class Finish < BaseLogic

      def think
        log "Congratulations, we're Finished booking your next appointment!"
      end

      def sms_and_voice
        twiml_final_report
      end

    end
  end
end

