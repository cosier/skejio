module Skej
  module Appointments
    module Detectors
      class BreakDetector < BaseDetector

        def detect(timeblock)
          @start_time = timeblock.start_time

          matches = []
          matches.flatten
        end

        private

        def params
          {
            business_id: session.business_id,
            office_id: session.chosen_office.id,
            service_id: session.chosen_service.id,
            provider_id: session.chosen_provider.id
          }
        end

      end
    end
  end
end

