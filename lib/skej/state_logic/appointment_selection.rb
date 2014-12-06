module Skej
  module StateLogic
    class AppointmentSelection < BaseLogic

      def think
        # Load up the AppointmentSelectionState machine
        @appointment = AppointmentSelectionState.machine(@session)
        @appointment.logic.process!
      end

      # Dynamically dispatch to the renderer— provided by the logic module
      def sms_and_voice
        # Dispatch!
        if @appointment.logic.respond_to? :sms_and_voice
          @appointment.logic.sms_and_voice

        elsif @session.sms?
          @appointment.logic.sms

        elsif @session.voice?
          @appointment.logic.voice

        else
          raise "Unmatched sms/voice dispatch to sub appointment logic gate"
        end
      end

    end
  end
end

