module Skej
  module Appointments
    module Detectors
      class BreakDetector < BaseDetector

        def detect(timeblock)
          matches = []
          matches << process_block(timeblock)
          pre_collect = matches.flatten.uniq
          pre_collect.map { |el| el }
        end

      private

       def process_block(tb)
          collided    = []
          tb_range    = Skej::Ranges::Seq.new(tb.range)
          breakshifts = Skej::Ranges::Seq.new

          all(tb).each { |bs| breakshifts.add(bs.range) }

          intersections = (tb_range & breakshifts)
          if intersections.present?

            # Arrayify our intersection results for consistency
            intersections = [intersections] unless intersections.kind_of? Array
            intersections.each do |inter|

              # Query for our BreakShift candidates within the current
              # TimeBlock begin/end range.
              matches = BreakShift.where(params)
                .where("start_hour   >= #{inter.begin.hour}")
                .where("start_minute >= #{inter.begin.minute}")
                .where("end_hour     <= #{inter.end.hour}")
                .where("end_minute   <= #{inter.end.minute}")

              # Only Add Breaks to the final collided collection,
              # IF they have passed floating inspection as well.
              #
              # Calling #can_float? on a BreakShift will determine the
              # if it can be floated elsewhere, and thus not need be counted
              # as a direct BreakShift hit.
              #
              collided << matches.select { |b|
                b.session = session
                # Only return true for those who cannot float,
                # and are therefore unmovable and valid collision.
                b.can_float? ? nil : true
              }
            end
          end

          # Return the aggregated collection of all collided BreakShift entities
          collided.flatten.compact
        end

        def all(tb)
          BreakShift.where(params)
            .with_day(day tb)
            .all
            .map { |b| b.session = session and b }
        end

        def params
          data = {
            business_id: session.business_id,
            office_id:   [(session.chosen_office.id rescue nil), nil],
            service_id:  [(session.chosen_service.id rescue nil), nil],
          }

          # Todo: take into consideration the possibility of :defferred
          # for session provider assignment.
          if session.chosen_provider.present?
            data[:provider_id] = [session.chosen_provider.id, nil]
          end

          data
        end

      end
    end
  end
end

