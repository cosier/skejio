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
            results << generate_appointment
          end

          results
        end

        def session
          @session
        end

        def generate_appointment(opts = {})

          biz_id = @session.business.id
          prv_id = @session.business.service_providers.first.id
          cst_id = @session.customer.id
          off_id = @session.chosen_office.id
          ses_id = @session.id

          opts.reverse_merge! start: random_range_start
          opts.reverse_merge! end: random_range_end(opts[:start])

          Appointment.new do |ap|
            # Required fields
            ap.business_id = biz_id
            ap.service_provider_id = prv_id
            ap.customer_id = cst_id
            ap.office_id = off_id
            ap.created_by_session_id = ses_id

            ap.start = opts[:start]
              .to_datetime
              .change(@session.chosen_office.timezone)

            ap.end   = opts[:end]
              .to_datetime
              .change(@session.chosen_office.timezone)
          end
        end

        # Fetch the timezone for the chosen office.
        #
        # While also memoizing the timezone result as
        # @timezone_cache
        def timezone
          return @timezone_cache if @timezone_cache

          # Get the office id from the session json store
          id = @session.store[:chosen_office_id]
          office = Office.where(business_id: @session.business_id, id: id).first

          if office.present?
            @timezone_cache = office.timezone
          end

          @timezone_cache

        end

        # Generate a random range to start with.
        def random_range_start
          DateTime.now + (rand(1..30) * 30).minutes
        end

        # Add a random amount of blocks (30min per block)
        # to the end of an existing start.
        def random_range_end(start)
          start + (rand(1..5) * 30).minutes
        end

    end
  end
end
