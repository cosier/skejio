module Skej
  module Appointments
    class Query

      # Initialize our query from a single Session
      def initialize(sesh)
        @session = sesh
      end

      def available_now
        mock_results
      end

      def list(opts = {})
      end

      private

        def mock_results
          results = []
          now = DateTime.now

          1.times do |n|
            results << Appointment.new do |ap|
              binding.pry
              ap.id
            end
          end

          results
        end

        def session
          @session
        end

        def timezone
          # Get the office id from the session json store
          id = @session.store[:chosen_office_id]
          office = Office.where(business_id: @session.business_id, id: id).first
          office.present? office.time_zone : false
        end

    end
  end
end
