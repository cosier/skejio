module Skej
  module StateLogic
    class AppointmentSelection < BaseLogic

      def think
        log "appointment.logic.process!"
        appointment_state.logic.process!
      end

      def sms_and_voice
        log "appointment.logic.render"
        # Delegate to the logic renderer
        sub_render = appointment_state.logic.render
        sub_render
      end

      def appointment_state
        # Load up the AppointmentSelectionState machine
        @appointment ||= AppointmentSelectionState.machine(@session)
      end

      alias_attribute :ap, :appointment_state

    end
  end
end

