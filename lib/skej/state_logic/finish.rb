module Skej
  module StateLogic
    class Finish < BaseLogic

      def think
        @session.update! is_finished: true
        @appointment = session.chosen_appointment
      end

      def sms_and_voice
        twiml_final_report(appointment: @appointment)
      end

      private


    end
  end
end

