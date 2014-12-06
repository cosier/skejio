module Skej
  module StateLogic
    class AppointmentSelection < BaseLogic

      def think
        # Load up the AppointmentSelectionState machine
        @appointment = AppointmentSelectionState.machine(@session)
      end

      def sms_and_voice

        twiml_ask_appointment_selection
      end

    end
  end
end

