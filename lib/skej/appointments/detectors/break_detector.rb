module Skej
  module Appointments
    module Detectors
      class BreakDetector < BaseDetector

        def detect(timeblock)
          matches = []
          matches << process_primary_matches(timeblock)
          matches << process_secondary_matches(timeblock)
          matches.flatten.uniq
        end

        private

        def process_primary_matches(tb)
          base_query = BreakShift.where(params).with_day(day tb)
          started    = BreakShift.started_between(tb.start_time, tb.end_time, base_query).all
          ending     = BreakShift.ending_between(tb.start_time, tb.end_time, base_query).all

          [started, ending]
        end

        # Determines the Day Of the Week in accordance to Office timezone and
        # natural language processing.
        def day(tb)
          Skej::NLP.parse(session, tb.start_time).strftime('%A').downcase.to_sym
        end

        def process_secondary_matches(timeblock)
          left  = process_primary_matches(timeblock.previous)
          right = process_primary_matches(timeblock.next)
          [left, right]
        end

        def params
          {
            business_id: session.business_id,
            office_id:   [session.chosen_office.id, nil],
            service_id:  [session.chosen_service.id, nil],
            provider_id: [session.chosen_provider.id, nil]
          }
        end

      end
    end
  end
end

