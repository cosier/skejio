module Skej
  module Appointments
    module Detectors
      class BaseDetector

        def initialize(opts = {})
          @session = opts[:session]
        end

        def detect(time)
          []
        end

        private

        def start_time
          @start_time
        end

        def end_time
          start_time + session.chosen_service.duration.minutes
        end

        def session
          @session
        end

      end
    end
  end
end

