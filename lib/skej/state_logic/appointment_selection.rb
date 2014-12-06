module Skej
  module StateLogic
    class AppointmentSelection < BaseLogic

      def think
        # Load up the AppointmentSelectionState machine
        @appointment = AppointmentSelectionState.machine(@session)
        @appointment.logic.process!
      end

      def sms_and_voice
        # Delegate to the logic renderer
        @appointment.logic.render
      end

    end
  end
end

