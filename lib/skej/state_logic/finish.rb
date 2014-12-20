module Skej
  module StateLogic
    class Finish < BaseLogic

      def think
        # We need to go back if we still somehow don't have an appointment?
        # Note: This shouldn't be possible anyways
        return reverse! if session.chosen_appointment.nil?

        @session.update! is_finished: true
        @appointment = session.chosen_appointment
      end

      def sms_and_voice
        twiml_final_report(appointment: @appointment)
      end

      private

      def reverse!
        mark_as_completed!
        @session.reset_appointment_selection!
      end

    end
  end
end

