module Skej
  module StateLogic
    class AppointmentSelection < BaseLogic

      def think
        log "appointment.logic.process!"

        # We mark it as completed right away,
        # so when we jump around to other states we won't have any
        # issues passing the transition guards.
        mark_as_completed!

        # Engage the sub logic module processing of the Appointment Statemachine.
        session.appointment.logic.process!

      end

      def sms_and_voice
        log "appointment.logic.render"

        # Delegate to the logic renderer
        sub_render = session.appointment.logic.render
        sub_render
      end


    end
  end
end

