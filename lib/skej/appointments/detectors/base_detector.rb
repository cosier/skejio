module Skej
  module Appointments
    module Detectors
      class BaseDetector

        def initialize(opts = {})
          @session = opts[:session]
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

        def initialize_start_time(time)
          @start_time = time
        end

        # Determines the Day Of the Week in accordance to Office timezone and
        # natural language processing.
        def day(tb)
          Skej::NLP.parse(session, tb.start_time).strftime('%A').downcase.to_sym
        end

      end
    end
  end
end

