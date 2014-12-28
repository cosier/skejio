module Skej
  module Appointments
    module Detectors
      class AppointmentDetector < BaseDetector

        def detect(timeblock)
          @start_time = timeblock.start_time

          matches = []
          matches << started_appointments
          matches << ending_appointments
          matches.flatten
        end

        private

        def started_appointments
          Appointment.where(params.reverse_merge(start: start_time..end_time)).all
        end

        def ending_appointments
          Appointment.where(params.reverse_merge(end: start_time..end_time)).all
        end

        def params
          {
            business_id: session.business_id,
            office_id: session.chosen_office.id,
            service_id: session.chosen_service.id,
          }
        end

      end
    end
  end
end

