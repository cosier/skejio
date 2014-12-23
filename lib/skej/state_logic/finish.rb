module Skej
  module StateLogic
    class Finish < BaseLogic

      def think
        @session.update! is_finished: true
        @appointment = session.appointment.chosen_appointment

        @provider_text = ""

        if session.can_change_provider?
          @provider_text = "with #{session.chosen_provider.display_name}" if session.chosen_provider.present?
        end
      end


      def sms_and_voice
        twiml_final_report(appointment: @appointment, provider_text: @provider_text)
      end

      private


    end
  end
end

