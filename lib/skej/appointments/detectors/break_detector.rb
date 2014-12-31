module Skej
  module Appointments
    module Detectors
      class BreakDetector < BaseDetector

        def detect(timeblock)
          matches = []
          matches << primary_block(timeblock)
          matches << boundary_blocks(timeblock)
          matches.flatten.uniq
        end

        private

        # Find any Breaks for a given TimeBlock
        def primary_block(tb)
          process_block(tb)
        end

        # Determines the Day Of the Week in accordance to Office timezone and
        # natural language processing.
        def day(tb)
          Skej::NLP.parse(session, tb.start_time).strftime('%A').downcase.to_sym
        end

        def boundary_blocks(primary_timeblock)
          # We don't need to check the boundary blocks if we don't need to
          # push our own break sideways.
          return [] if process_block(primary_timeblock).empty?

          matches = []
          tb      = primary_timeblock
          left    = process_block(tb.previous)
          right   = process_block(tb.next)

          if tb.next.has_appointment? and tb.next(2).has_appointment?
            matches << right
          end

          if tb.previous.has_appointment? and tb.previous(2).has_appointment?
            matches << left
          end

          # Return the aggregated left & right collisions.
          matches.flatten
        end

        def process_block(tb)
          base_query = BreakShift.where(params).with_day(day tb)
          started    = BreakShift.started_between(tb.start_time, tb.end_time, base_query).all
          ending     = BreakShift.ending_between(tb.start_time, tb.end_time, base_query).all

          [started, ending].flatten
        end

        def params
          data = {
            business_id: session.business_id,
            office_id:   [session.chosen_office.id, nil],
            service_id:  [session.chosen_service.id, nil],
          }

          if session.chosen_provider.present?
            data[:provider_id] = [session.chosen_provider.id, nil]
          end

          data
        end

      end
    end
  end
end

