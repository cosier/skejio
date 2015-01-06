module Skej
  module Appointments
    module Detectors
      class AppointmentDetector < BaseDetector

        def detect(timeblock)
          # Setup our starting time boundary
          # (end boundary is auto calculated based on service duration).
          initialize_start_time(timeblock.start_time)
          process_block(timeblock)
        end

        private

        def process_block(tb)
          collided     = []
          tb_range     = Skej::Ranges::Seq.new(tb.range)
          appointments = Skej::Ranges::Seq.new

          all(tb).each { |bs| appointments.add(bs.range) }

          intersections = appointments.intersect_with(tb.range)

          if intersections.present?
            # Arrayify our intersection results for consistency
            intersections = [intersections] unless intersections.kind_of? Array
            intersections.each do |inter|
              results = []
              results << Appointment.where(start_time: inter).where(params).all
              results << Appointment.where(end_time: inter).where(params).all

              collided << results.flatten.map { |b| b.session = session and b }
            end
          end

          collided.flatten.compact
        end

        def all(tb)
          midnight = Skej::NLP.midnight(session)
          range = midnight - 24.hours..midnight + 24.hours

          Appointment.where(params)
            .where(start_time: range)
            .all.map { |b|
              b.created_by_session_id = session.id
              b.session = session and b
            }
        end

        def params
          data = {
            business_id: session.business_id,
            office_id: session.chosen_office.id,
            service_provider_id: session.chosen_provider.id
          }
        end

      end
    end
  end
end

