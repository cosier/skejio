module Skej
  module StateLogic
    class AppointmentSelection < BaseLogic

      def think
        # Load up the AppointmentSelectionState machine
        @appointment = AppointmentSelectionState.machine(@session)
        @appointment.logic.process!
      end

      # Dynamically dispatch to the renderer
      # based on the current_state
      def sms_and_voice
        now = @appointment.current_state.to_sym
        # Dispatch!
        self.send "twiml_appointments_#{now}"
      end

    end
  end
end

