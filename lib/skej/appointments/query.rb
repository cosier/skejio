module Skej
  module Appointments
    class Query

      # Initialize our query from a single Session
      def initialize(sesh)
        @session = sesh
      end

      def available_now(base_date)
        # Stash this for future use, as we will be using it to set a baseline date
        # in order to derive a bunch of different appointments from.
        @base_date = base_date

        # For now just generate a bunch of valid Appointments.
        # Using random dates (with realistic start/end ranges generated)
        mock_results
      end

      def list(opts = {})
      end

      private

        def mock_results
          results = []
          now = DateTime.now

          3.times do |n|
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

          # Optionally merge in start and end dates,
          # if not already provided.
          opts.reverse_merge! start: random_range_start
          opts.reverse_merge! end: random_range_end(opts[:start])

          # Instantiate an Appointment model with all the
          # right properties.
          #
          # Note: This is not saved to the database yet.
          # (most likely pending confirmation/selection at this point)
          Appointment.new do |ap|
            # Required fields
            ap.business_id = biz_id
            ap.service_provider_id = prv_id
            ap.customer_id = cst_id
            ap.office_id = off_id
            ap.created_by_session_id = ses_id

            # Ensure :start is transformed to a DateTime.
            # As well as applying any time_zone transformations.
            ap.start = opts[:start]
              .to_datetime
              .in_time_zone(@session.chosen_office.time_zone)

            # Ensure :end is transformed to a DateTime.
            # As well as applying any time_zone transformations.
            ap.end   = opts[:end]
              .to_datetime
              .in_time_zone(@session.chosen_office.time_zone)

          end
        end

        # Fetch the timezone for the chosen office.
        #
        # While also memoizing the time_zone result as
        # @time_zone_cache
        def time_zone
          return @time_zone_cache if @time_zone_cache

          # Get the office id from the session json store
          id = @session.store[:chosen_office_id]
          office = Office
            .where(business_id: @session.business_id, id: id)
            .first

          if office.present?
            @time_zone_cache = office.time_zone
          end

          @time_zone_cache

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
