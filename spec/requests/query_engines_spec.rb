require 'rails_helper'

describe Skej::Appointments::QueryEngine, :type => :request do

  #############################################################################
  # SCENARIO: 1
  #############################################################################
  context "Available TimeSlots with Collisions" do

    let(:engine) {
      create_engine(
        service_duration: 60, # 60 minute blocks
        services: [60, 120],
        time_entries: [{ start_hour: 9, end_hour: 15, day: :now }],
        break_entries: [{ start_hour: 12, end_hour: 13, day: :now }])
    }

    describe '#available_on' do
      context "Using the current time as input" do
        let(:results) { engine.available_on :now }

        it 'should contain only Appointment members' do
          results.each { |result| expect(result).to be_a Appointment  }
        end

        it 'should contain a few results' do
          expect(results.count).to be > 1
        end
      end
    end

  end #END SCENARIO: 1

  #############################################################################
  # SCENARIO: 2
  #############################################################################
  context "Available TimeSlots with Multiple Collisions" do
    let(:engine) {
      create_engine(
        service_duration: 15,
        services:       [10, 15, 20, 30], # minimum 10 minute TimeBlocks

        # TimeEntry   9:00-10:00 - 1 hour
        time_entries:   [{ start_hour: 9,
                           end_hour: 10,
                           day: :now }],

        # Break       9:30-9:40 - 10 minutes
        break_entries:  [{ start_hour: 9,
                           start_minute: 30,
                           end_hour: 9,
                           end_minute: 40,
                           day: :now }],

        # Appointment 9:40-10:00 - 20
        appointments:   [{ start_hour: 9, start_minute: 40, end_hour: 10 }])
    }

    # Test the available TimeSlots returned by the API
    describe '#extract_available_slots' do
      let(:time_slots) {
        engine.extract_available_slots(engine.all_time_entries.first) }

      it 'should produce exactly 2 available slots' do
        expect(time_slots.count).to be 2
      end

    end

    # Test the available Appointments returned by the API
    # Note: These are Available Appointments, not existing ones.
    describe '#available_on' do
      let(:appointments) { engine.available_on(:now) }

      it 'should have 2 appointments' do
        expect(appointments.count).to be 2
      end

      it 'should contain the exact time slots' do
        apt_expect! appointments[0], [9,00, 9,15]
        apt_expect! appointments[1], [9,15, 9,30]
      end

    end
  end # END SCENARIO: 2


  #############################################################################
  # SCENARIO: 3
  #############################################################################
  context "Available TimeSlots with Floating Breaks" do
    let(:engine) {

      # Notes:
      # 4 TimeSlots expected, since we have no appointments set, we won't
      # run into any Break collisions (as the break can float).
      create_engine(
        service_duration: 15,
        services:       [10, 15, 20, 30], # minimum 10 minute TimeBlocks

        # TimeEntry   9:00-10:00 - 9 hour shift 36 slots
        time_entries:   [{ start_hour: 10, end_hour: 11, day: :now }],

        # Break       10:30-11:00 - 30 minute break - with ability to
        #             float -+ 30 mins.
        break_entries:  [
          { start_hour: 10,
            start_minute: 30,
            end_hour: 11,
            day: :now,
            float: 30 }
        ])
    }

    # Test the available TimeSlots returned by the API
    describe '#extract_available_slots' do
      let(:time_slots) {
        engine.extract_available_slots engine.all_time_entries.first
      }

      it 'should produce exactly 4 available slots' do
        expect(time_slots.count).to be 4
      end
    end

    # Test the available Appointments returned by the API
    # Note: These are Available Appointments, not existing ones.
    describe '#available_on' do
      let(:appointments) { engine.available_on(:now) }

      # Due to the amount of available time slots, we should always have
      # at least 3 available appointment responses.
      it 'should have 4 appointments' do
        expect(appointments.count).to be 4
      end

      it 'should contain the exact time slots' do
        apt_expect! appointments[0], [10,00, 10,15]
        apt_expect! appointments[1], [10,15, 10,30]
        apt_expect! appointments[2], [10,30, 10,45]
        apt_expect! appointments[3], [10,45, 11,00]
      end
    end

  end # END SCENARIO: 3


  #############################################################################
  # SCENARIO: 4
  #############################################################################
  context "Available TimeSlots with Many Appointment Collision" do
    let(:engine) {
      # Notes:
      # Expecting 22 free TimeBlocks:
      #
      #   9 Hour TimeEntry  = 36 TimeSlots
      #   _________________________
      #
      #   1/2 Hour Break    = 02 TimeSlots
      #   3 Appointments    = 12 TimeSlots
      #   _________________________
      #
      #   36 - 16 = Available 22 TimeSlots
      #
      #
      create_engine(
        service_duration: 15,
        services:       [10, 15, 20, 30], # minimum 10 minute TimeBlocks

        # TimeEntry   9:00-10:00 - 9 hour shift 36 slots
        time_entries:   [{ start_hour: 8, end_hour: 17, day: :now }],

        # Break       12:30-13:00 - 30 minute break - 2 slots
        break_entries:  [{ start_hour: 12,
                           start_minute: 30,
                           end_hour: 13,
                           float: 0,
                           day: :now }],

        # Appointment - a bunch of 1 hour appointments
        appointments:   [
          { start_hour: 10, end_hour: 11 }, # 4 slots / 15
          { start_hour: 13, end_hour: 14 }, # 4 slots / 15
          { start_hour: 15, end_hour: 16 }, # 4 slots / 15
        ])
    }

    # Test the available TimeSlots returned by the API
    describe '#extract_available_slots' do
      let(:time_slots) {
        engine.extract_available_slots(engine.all_time_entries.first) }

      it 'should produce exactly 22 available slots' do
        expect(time_slots.count).to be 22
      end
    end

    # Test the available Appointments returned by the API
    # Note: These are Available Appointments, not existing ones.
    describe '#available_on' do
      let(:appointments) { engine.available_on(:now) }

      # Due to the amount of available time slots, we should always have
      # at least 3 available appointment responses.
      it 'should have 22 appointments' do
        expect(appointments.count).to be 22
      end

    end
  end # END SCENARIO: 4

  #############################################################################
  # SCENARIO: 5
  #############################################################################
  context "Break timeslot should be usable if not sandwiched by Appointments" do
    let(:engine) {
      # Notes:
      # Expecting 6 free TimeBlocks due to the ability to float
      # the 1 break we have. Allowing us to provide that break timeslot
      # to the customer as well.
      #
      # Since we have no appointment collisions here, this is just a empty
      # floating test scenario.
      #
      create_engine(
        service_duration: 10,  # Chosen service will have a duration of this
        services:        [15], # Any additional services to be created

        # TimeEntry   8:00-9:00 - 1 hour shift - 6 slots
        time_entries:   [{ start_hour: 8, end_hour: 9, day: :now }],

        # Break       8:30-8:40 - 10 minute break - 1 slot
        break_entries:  [{ start_hour: 8,
                           start_minute: 30,
                           end_hour: 8,
                           end_minute: 40,
                           float: 10,
                           day: :now }],

        # Appointment - none
        appointments:   [])
    }

    # Test the available TimeSlots returned by the API
    describe '#extract_available_slots' do
      let(:time_slots) {
        engine.extract_available_slots(engine.all_time_entries.first) }

      it 'should produce 6 available slots' do
        expect(time_slots.count).to be 6
      end
    end

    # Test the available Appointments returned by the API
    # Note: These are Available Appointments, not existing ones.
    describe '#available_on' do
      let(:appointments) { engine.available_on(:now) }

      # Due to the amount of available time slots, we should always have
      # at least 3 available appointment responses.
      it 'should have 6 appointments' do
        expect(appointments.count).to be 6
      end

      it 'should contain the exact time slots' do
        apt_expect! appointments[0], [8,00, 8,10]
        apt_expect! appointments[1], [8,10, 8,20]
        apt_expect! appointments[2], [8,20, 8,30]
        apt_expect! appointments[3], [8,30, 8,40]
        apt_expect! appointments[4], [8,40, 8,50]
        apt_expect! appointments[5], [8,50, 9,00]
      end

    end
  end # END SCENARIO: 5

  #############################################################################
  # SCENARIO: 6
  #############################################################################
  context "Break between 2 Appointments should not be floatable" do
    let(:engine) {
      # Notes:
      # Expecting 3 free TimeBlocks, due to 2 appointments and a non-movable
      # Break- which is floatable.
      #
      create_engine(
        service_duration: 10,  # Chosen service will have a duration of this
        services:        [15], # Any additional services to be created

        # TimeEntry   8:00-9:00 - 1 hour shift - 6 slots
        time_entries:   [{ start_hour: 8, end_hour: 9, day: :now }],

        # Break       8:30-8:40 - 10 minute break - 1 slot
        break_entries:  [{ start_hour: 8,
                           start_minute: 30,
                           end_hour: 8,
                           end_minute: 40,
                           float: 10,
                           day: :now }],

        appointments:   [
          { start_hour: 8, start_minute: 20, end_minute: 30},  # 1 slot
          { start_hour: 8, start_minute: 40, end_minute: 50}]) # 1 slot
    }

    # Test the available TimeSlots returned by the API
    describe '#extract_available_slots' do
      let(:time_slots) {
        engine.extract_available_slots(engine.all_time_entries.first) }

      it 'should produce exactly 3 available slots' do
        expect(time_slots.count).to be 3
      end
    end

    describe '#available_on' do
      let(:appointments) { engine.available_on(:now) }

      it 'should have only 3 available appointments' do
        expect(appointments.count).to be 3
      end

      it 'should contain the exact time slots' do
        apt_expect! appointments[0], [8,00, 8,10]
        apt_expect! appointments[1], [8,10, 8,20]
        apt_expect! appointments[2], [8,50, 9,00]
      end

    end
  end # END SCENARIO: 6


  #############################################################################
  # SCENARIO: 7
  #############################################################################
  context "Break after an Appointments can still float right" do
    let(:engine) {
      # Notes:
      # Expecting 3 free TimeBlocks, due to 2 appointments and a non-movable
      # Break- which is floatable.
      #
      create_engine(
        service_duration: 10,  # Chosen service will have a duration of this
        services:        [15], # Any additional services to be created

        # TimeEntry   8:00-9:00 - 1 hour shift - 6 slots
        time_entries:   [{ start_hour: 8, end_hour: 9, day: :now }],

        # Break       8:30-8:40 - 10 minute break - 1 slot (will float)
        break_entries:  [{ start_hour: 8,
                           start_minute: 30,
                           end_hour: 8,
                           end_minute: 40,
                           float: 10,
                           day: :now }],

        # Single Appointment to the left of the Break - 1 slot
        appointments:   [{ start_hour: 8, start_minute: 20, end_minute: 30}])
    }

    # Test the available TimeSlots returned by the API
    describe '#extract_available_slots' do
      let(:time_slots) {
        engine.extract_available_slots(engine.all_time_entries.first) }

      it 'should produce exactly 5 available slots' do
        expect(time_slots.count).to be 5
      end
    end

    # Test the available Appointments returned by the API
    # Note: These are Available Appointments, not existing ones.
    describe '#available_on' do
      let(:appointments) { engine.available_on("now") }

      it 'should have only 5 available appointments' do
        expect(appointments.count).to be 5
      end

      it 'should contain the exact time slots' do
        apt_expect! appointments[0], [8,00, 8,10]
        apt_expect! appointments[1], [8,10, 8,20]
        apt_expect! appointments[2], [8,30, 8,40] # the floated break
        apt_expect! appointments[3], [8,40, 8,50]
        apt_expect! appointments[4], [8,50, 9,00]
      end

    end
  end # END SCENARIO: 7

  #############################################################################
  # SCENARIO: 8
  #############################################################################
  context "Break before an Appointments can still float left" do
    let(:engine) {
      # Notes:
      # Expecting 3 free TimeBlocks, due to 2 appointments and a non-movable
      # Break- which is floatable.
      #
      create_engine(
        service_duration: 10,  # Chosen service will have a duration of this
        services:        [15], # Any additional services to be created

        # TimeEntry   8:00-9:00 - 1 hour shift - 6 slots
        time_entries:   [{ start_hour: 8, end_hour: 9, day: :now }],

        # Break       8:30-8:40 - 10 minute break - 1 slot (will float)
        break_entries:  [{ start_hour: 8,
                           start_minute: 30,
                           end_hour: 8,
                           end_minute: 40,
                           float: 10,
                           day: :now }],

        # Single Appointment to the left of the Break - 1 slot
        appointments:   [{ start_hour: 8, start_minute: 40, end_minute: 50}])
    }

    # Test the available TimeSlots returned by the API
    describe '#extract_available_slots' do
      let(:time_slots) {
        engine.extract_available_slots(engine.all_time_entries.first) }

      it 'should produce exactly 5 available slots' do
        expect(time_slots.count).to be 5
      end
    end

    # Test the available Appointments returned by the API
    # Note: These are Available Appointments, not existing ones.
    describe '#available_on' do
      let(:appointments) { engine.available_on(:now) }

      it 'should have only 5 available appointments' do
        expect(appointments.count).to be 5
      end

      it 'should contain the exact time slots' do
        apt_expect! appointments[0], [8,00, 8,10]
        apt_expect! appointments[1], [8,10, 8,20]
        apt_expect! appointments[2], [8,20, 8,30]
        apt_expect! appointments[3], [8,30, 8,40]
        apt_expect! appointments[4], [8,50, 9,00]
      end

    end
  end # END SCENARIO: 8

  #############################################################################
  # SCENARIO: 9
  #############################################################################
  context "Window generation should yield no deadspace" do
    let(:engine) {
      # Notes:
      # Expecting 3 free TimeBlocks, due to 2 appointments and a non-movable
      # Break- which is floatable.
      #
      create_engine(
        service_duration: 10,  # Chosen service will have a duration of this
        services:        [15], # Any additional services to be created

        # TimeEntry   8:00-9:05 - 1 hour shift - 6 slots
        time_entries:   [{ start_hour: 8,
                           end_hour: 9,
                           end_minute: 05,
                           day: :now }])
    }

    # Test the available TimeSlots returned by the API
    describe '#extract_available_slots' do
      let(:time_slots) {
        engine.extract_available_slots(engine.all_time_entries.first) }

      it 'should produce exactly 7 available slots' do
        expect(time_slots.count).to be 7
      end
    end

    # Test the available Appointments returned by the API
    # Note: These are Available Appointments, not existing ones.
    describe '#available_on' do
      let(:appointments) { engine.available_on(:now) }

      it 'should have only 3 available appointments' do
        expect(appointments.count).to be 5
      end

      it 'should contain the exact time slots' do
        apt_expect! appointments[0], [8,00, 8,10]
        apt_expect! appointments[1], [8,10, 8,20]
        apt_expect! appointments[2], [8,20, 8,30]
        apt_expect! appointments[3], [8,30, 8,40]
        apt_expect! appointments[4], [8,50, 9,00]
      end

    end
  end # END SCENARIO: 9

end
