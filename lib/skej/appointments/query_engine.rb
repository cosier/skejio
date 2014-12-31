module Skej
  module Appointments
    # Responsible for Determining available Appointment Times,
    # based a myriad of factors.
    class QueryEngine
      # Initialize our query from a single Session
      def initialize(sesh)
        @session = sesh
      end

      # Main method for getting all Available TimeBlock(s) for a given date.
      #
      # +:base_time: - DateTime used for determining the base scan date range.
      def available_on(base_time)
        # Stash this for future use, as we will be using it to set a
        # baseline date in order to derive a bunch of different appointments
        # from.
        set_base_time(base_time)
        time_entries = time_entries_for(base)

        # Transform TimeEntry(s) -> TimeBlock(s).
        all_blocks = extract_time_blocks(time_entries)

        # Run Validation and Collision detection on all found known TimeBlock(s)
        open_blocks = validate_time_blocks(all_blocks)

        # Optimize & Filter our wide collection of TimeBlocks.
        optimized_blocks = optimize_time_blocks(open_blocks)

        # Finally, present the TimeBlock(s) as Appointment records
        # to the Customer.
        transform_blocks_to_appointments(optimized_blocks)
      end

      # Return all valid TimeBlock(s) for a given base time.
      def valid_blocks(base_time)
        set_base_time(base_time)
        time_entries = time_entries_for(base)

        # Transform TimeEntry(s) -> TimeBlock(s).
        all_blocks = extract_time_blocks(time_entries)

        # Run Validation and Collision detection on all found known TimeBlock(s)
        validate_time_blocks(all_blocks)
      end

      # Returns all valid Appointments for a given base time.
      def valid_appointments(base_time)
        transform_blocks_to_appointments(valid_blocks(base_time))
      end

      private

      # Get all TimeEntry(s) that match the current session properties.
      #
      # +:target_date+ - A DateTime to base the TimeEntry collection query from.
      def time_entries_for(target_date)
        target_day = target_date.strftime('%A').downcase.to_sym
        TimeEntry.where(build_query_params).with_day(target_day)
      end

      def build_query_params
        # From 100 years up to now
        valid_from_range  = (DateTime.now - 100.years)..DateTime.now

        # From now up to 100 years
        valid_until_range = DateTime.now..(DateTime.now + 100.years)

        query_params = {
          business_id:    session.business.id,
          office_id:      [session.chosen_office.id, nil],
          service_id:     [session.chosen_service.id, nil],
          valid_until_at: [valid_until_range, nil],
          valid_from_at:  [valid_from_range, nil],
          is_enabled:     true
        }

        if session.chosen_provider.present?
          query_params[:provider_id] = [session.chosen_provider.id, nil]
        end

        query_params
      end

      # Slice up many TimeEntry(s) records into even more tiny slices,
      # individually called a TimeBlock
      #
      # +:time_entries+ - A collection of TimeEntry(s) activerecord
      # model instances.
      def extract_time_blocks(time_entries)
        results = time_entries.map do |entry|

          # Create a date based n todays date, but with the time changed to
          # that of the entry start/end.
          entry_start = base.change(hour: entry.start_hour, minute: entry.start_minute)

          # By rounding off with #floor, we go the easy route (no partial time blocks)
          blocks = (entry.duration / block_size).floor.times.map do |i|

            start_time = Skej::Warp.zone(
              entry_start + (i * block_size).minutes,
              session.chosen_office.time_zone)

            end_time   = Skej::Warp.zone(
              start_time + block_size.minutes,
              session.chosen_office.time_zone)

            target_day = Skej::NLP.parse(session, entry.day)
                                  .strftime('%A')
                                  .downcase
                                  .to_sym

            TimeBlock.new(
              session: session,
              time_entry_id: entry.id,
              business_id: session.business_id,
              time_sheet_id: entry.time_sheet_id,
              office_id: entry.office_id,
              day: target_day,
              start_time: start_time,
              end_time: end_time)

          end
        end.flatten

        return results
      end

      # Given a collection of TimeBlock(s),
      # return only the ones that have no detectable collisions
      # (and thus are valid).
      #
      # +:time_blocks+ - All extracted TimeBlock(s) you wish to have validated.
      def validate_time_blocks(time_blocks)
        time_blocks.select(&:in_future?).select(&:collision_free?)
      end

      # Given a collection of TimeBlock(s),
      # return a more optimized subset of the given collection.
      #
      # +:time_blocks: - Collection of TimeBlock(s) to be
      # filtered and optimized.
      def optimize_time_blocks(time_blocks)
        Optimizer.new.optimize(time_blocks)
      end

      def transform_blocks_to_appointments(time_blocks)
        time_blocks.map do |tb|
          generate_appointment(
            prv_id: tb.service_provider.id,
            start:  tb.start_time,
            end:    tb.end_time)
        end
      end

      # The size of a TimeBlock.
      # Based on the minute duration of the chosen Service.
      def block_size
        session.chosen_service.duration
      end

      def generate_appointment(opts = {})
        biz_id = opts[:biz_id] || @session.business.id
        prv_id = opts[:prv_id] || @session.business.service_providers.first.id
        cst_id = opts[:cst_id] || @session.customer.id

        off_id = opts[:off_id] || @session.chosen_office.id
        srv_id = opts[:srv_id] || @session.chosen_service.id
        ses_id = opts[:ses_id] || @session.id

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
          ap.service_id = srv_id
          ap.created_by_session_id = ses_id

          # Ensure :start is transformed to a DateTime.
          # As well as applying any time_zone transformations.
          ap.start = Skej::Warp.zone(
            opts[:start],
            @session.chosen_office.time_zone)

          # Ensure :end is transformed to a DateTime.
          # As well as applying any time_zone transformations.
          ap.end   = Skej::Warp.zone(
            opts[:end],
            @session.chosen_office.time_zone)

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
        base.to_datetime + (rand(1..30) * 30).minutes
      end

      # Add a random amount of blocks (30min per block)
      # to the end of an existing start.
      def random_range_end(start)
        start + (rand(1..5) * 30).minutes
      end

      # The date baseline we are going to be working off of.
      def base
        @base_time
      end

      def session
        @session
      end

      def set_base_time(original_input)
        unless original_input.present?
          target = DateTime.now
        else
          target = original_input
        end

        if target.kind_of? String or target.kind_of? Symbol
          # Allow for detection of Strings for NLP
          target = Skej::NLP.parse(session, target)

        else
          # Otherwise just straight convert to a datetime,
          # just to be sure.
          target = target.to_datetime
        end

        if target < DateTime.now
          @base_time = DateTime.now
        else
          @base_time = target
        end
      end

    end
  end
end
