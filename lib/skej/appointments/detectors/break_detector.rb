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

          all(tb).each do |bs|
            breakshifts.add(bs.range)
          end

          intersections = (tb_range & breakshifts)
          if intersections.present?

            # Arrayify our intersection results for consistency
            intersections = [intersections] unless intersections.kind_of? Array

            intersections.each do |inter|
              results = BreakShift.where(params)
                .where("start_hour >= #{inter.begin.hour}")
                .where("start_minute >= #{inter.begin.minute}")
                .where("end_hour <= #{inter.end.hour}")
                .where("end_minute <= #{inter.end.minute}")

              collided << results.select { |b|
                b.session = session
                b.can_float? ? b : nil
              }
            end
          end

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

