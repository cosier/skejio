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

        # Fetch all TimeEntris related for this date query.
        time_entries = time_entries_for(base)

        # Transform TimeEntry(s) -> TimeSlot(s).
        available_slots = generate_time_slots(time_entries)

        # Combine all sequential linear slots to into a single window.
        # This produces multiple windows
        windows = combine_linear_slots(available_slots)

        # Generate TimeBlocks from the Available Slot ranges
        open_time_blocks = generate_time_blocks(windows)

        # Optimize & Filter our wide collection of TimeBlocks.
        optimized_blocks = optimize_time_blocks(open_time_blocks)

        # Finally, present the TimeBlock(s) as Appointment records
        # to the Customer.
        final = transform_blocks_to_appointments(optimized_blocks)
      end

      # Public api for returning all collisions for a given Range.
      #
      # The Range is transformed into a TimeBlock, and then pushed through
      # the pipeline for natural detection of any collisions.
      def collisions_for(range)
        collider.detect TimeBlock.new(
          start_time: range.begin,
          end_time: range.end,
          session: @session)
      end

      # Generate TimeSlots over a given range using the minimum service duration
      def time_slots_for(time_entry)
        count = (duration_for(time_entry.range) / block_size).floor.to_i
        time = time_entry.start_time

        slots = count.times.map do |i|
          # Instantiate a new TimeSlot out of thin air (no backing store)
          slot = TimeSlot.new time, time + block_size.minutes, time_entry

          # Stash the current session onto the slot as well, so it may handle
          # some of it's own session based logic.
          slot.session = session

          # finally increment the time for the next iteration
          time = time + block_size.minutes

          slot
        end

        # Detect deadspace at the TimeSlot layer.
        # If found, we add a final TimeSlot to make up the difference.
        if time < time_entry.end_time
          slots << TimeSlot.new(time, time_entry.end_time, time_entry)
        end

        # Return the aggregated slot collection
        slots
      end

      # Return all valid TimeBlock(s) for a given base time.
      def valid_blocks(base_time)
        set_base_time(base_time)
        time_entries = time_entries_for(base)
      end

      # Returns all valid Appointments for a given base time.
      def valid_appointments(base_time)
        transform_blocks_to_appointments(valid_blocks(base_time))
      end

      def all_time_entries(target_date = false)
        # If not target_date set, use midnight of the current day.
        target_date = Skej::NLP.parse(@session, 'midnight') - 1.day unless target_date
        time_entries_for(target_date)
      end

      def extract_available_slots(time_entry)
        time_slot_ranges = time_slot_ranges_for(time_entry)
        collision_ranges = collision_ranges_for(time_entry)

        # Fetch the actual TimeSlot instances (not just ranges)
        time_slots    = time_slots_for time_entry
        intersections = collision_ranges.with time_slot_ranges

        # Iterate over all found intersections and remove any time_slots which
        # also intersect with any of the intersections.
        invalid_slots = intersections.compact.map { |x|
          time_slots.select { |ts|
            range = ts.range.begin + 10.seconds..ts.range.end - 10.seconds
            ts if [range, x].flatten.intersection.present?
          }
        }.flatten.uniq { |o| o.start_time }

        valid_slots = time_slots.select { |ts|
          ts unless invalid_slots.include? ts }.flatten.uniq

        # If we have empty valid slots, that is an indicator that no
        # we found no intersections to process.
        #
        # Therefore we need to set all time_slots as valid
        valid_slots = time_slots if valid_slots.empty? and collision_ranges.ranges.empty?

        # return all valid TimeSlots found
        valid_slots
      end

      private

      # Returns the amount of minutes that occur between a DateTime range
      def duration_for(range)
        raise "Range cannot be nil" if range.nil?
        raise "Durations can only be calculated for ranges" unless range.kind_of? Range
        ((range.end - range.begin) * 24 * 60).to_i
      end

      def collision_ranges_for(time_entry)
        Ranges::Seq.new collider.detect(time_entry).compact.map(&:range)
      end

      def time_slot_ranges_for(time_entry)
        Ranges::Seq.new time_slots_for(time_entry).map(&:range)
      end

      # Get all TimeEntry(s) that match the current session properties.
      #
      # +:target_date+ - A DateTime to base the TimeEntry collection query from.
      def time_entries_for(target_date)
        target_day = Skej::NLP.parse(session, target_date.to_s)
                              .strftime('%A')
                              .downcase
                              .to_sym

        TimeEntry.where(build_query_params).with_day(target_day).map do |entry|
          entry.session = session and entry
        end
      end

      # Produces TimeSlot(s) from a collection of TimeEntries
      def generate_time_slots(time_entries)
        time_entries.map { |entry| extract_available_slots(entry) }.flatten
      end

      # Produces TimeSlot(s) from a collection of TimeSlotWindows
      def generate_time_blocks(windows)
        results = windows.map do |window|

          # Create a date based n todays date, but with the time changed to
          # that of the entry start/end.
          entry_start = base.change(
            hour: window.start_time.hour,
            min: window.start_time.minute)

          # By rounding off with #floor, we go the easy route (no partial time blocks)
          # Note: iterator is zero based.
          blocks = (window.duration / block_size).floor.times.map { |i|

            start_time = Skej::Warp.zone(
              entry_start + (i * block_size).minutes,
              session.chosen_office.time_zone)

            end_time   = Skej::Warp.zone(
              start_time + block_size.minutes,
              session.chosen_office.time_zone)

            target_day = Skej::NLP.parse(session, window.day)
                                  .strftime('%A')
                                  .downcase
                                  .to_sym

            TimeBlock.new(
              session: session,
              time_entry_id: window.time_entry.id,
              business_id: session.business_id,
              time_sheet_id: window.time_sheet_id,
              office_id: window.office_id,
              day: target_day,
              start_time: start_time,
              end_time: end_time)

          }
        end.flatten # results
      end

      # Responsible combining a collection of slots into common groups,
      # defined by touching boundaries.
      #
      # +:slots: - Array / Collection of TimeSlot(s)
      #
      def combine_linear_slots(slots)
        last_slot  = false
        end_time   = false
        start_time = false
        flushed    = false # Tracks the current continuity chain
        count      = 0
        aggregate  = []
        debug = []

        slots.sort_by(&:start_time).each_with_index do |slot, i|
          # Very close to each other, mark it as a continuation
          # to the end_time.

          start_time = slot.start_time unless last_slot
          end_time   = slot.end_time unless last_slot

          if slot.start_time < (end_time + 30.seconds)
            debug << "slot:#{slot.start_time} - neighbor detected"
            end_time = slot.end_time

          elsif last_slot
            debug << "slot:#{slot.start_time} - gap detected"
            aggregate << TimeSlot.new(start_time, end_time, slot.time_entry)

            start_time = slot.start_time
            end_time = slot.end_time

          end

          last_slot = slot
        end

        aggregate << TimeSlot.new(start_time, end_time, last_slot.time_entry) if last_slot
        aggregate.uniq
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


      # Given a collection of TimeBlock(s),
      # return only the ones that have no detectable collisions
      # (and thus are valid).
      #
      # +:time_blocks+ - All extracted TimeBlock(s) you wish to have validated.
      def validate_time_blocks(time_blocks)
        b = time_blocks.select(&:collision_free?)

        # Test environment has unreliable data entry for start times.
        b = b.select(&:in_future?) unless Rails.env.test?

        b
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
            start_time:  tb.start_time,
            end_time:    tb.end_time)
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
        opts.reverse_merge! start_time: random_range_start
        opts.reverse_merge! end_time:   random_range_end(opts[:start_time])



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
          ap.start_time = Skej::Warp.zone(
            opts[:start_time],
            @session.chosen_office.time_zone)

          # Ensure :end is transformed to a DateTime.
          # As well as applying any time_zone transformations.
          ap.end_time   = Skej::Warp.zone(
            opts[:end_time],
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

      def collider
        @collider ||= Skej::Appointments::Collider.new(session)
      end

      def set_base_time(original_input)
        now = Skej::NLP.parse(session, :now)

        unless original_input.present?
          target = now
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

        if target < now
          @base_time = now
        else
          @base_time = target
        end
      end

    end
  end
end
