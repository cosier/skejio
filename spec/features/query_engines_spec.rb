require 'rails_helper'

feature "QueryEngine", :type => :feature do

  #############################################
  # SCENARIO: 1
  context "Available TimeSlots with Collisions" do

    before(:each) do
      TimeEntry.destroy_all
      BreakShift.destroy_all
    end

    let(:engine) {
      create_engine(
        service_duration: 60, # 60 minute blocks
        time_entries: [{ start_hour: 9, end_hour: 15, day: :now }],
        break_entries: [{ start_hour: 12, end_hour: 13, day: :now }])
    }

    describe '#available_on' do
      context "Using the current time as input — (basic query operations)" do
        let(:results) { engine.available_on DateTime.now }

        it 'should contain only Appointment members' do
          results.each { |result| expect(result).to be_a Appointment  }
        end

        it 'should contain a few results' do
          expect(results.count).to be > 1
        end
      end
    end

  end #END SCENARIO: 1

  #############################################
  # SCENARIO: 2
  context "Available TimeSlots with Multiple Collisions" do
    let(:engine) {
      create_engine(
        service_duration: 15,
        services:       [10, 15, 20, 30], # minimum 10 minute TimeBlocks

        # TimeEntry   9:00-10:00 - 1 hour
        time_entries:   [{ start_hour: 9, end_hour: 10, day: :now }], # 1hr block

        # Break       9:30-9:40 - 10 minutes
        break_entries:  [{ start_hour: 9, start_minute: 30, end_hour: 9, end_minute: 40, day: :now }],

        # Appointment 9:40-10:00 - 20 minutes
        appointments:   [{ start_hour: 9, start_minute: 40, end_hour: 10 }])
    }

    # Test the available TimeSlots returned by the API
    describe '#extract_available_slots' do
      let(:time_slots) { engine.extract_available_slots(engine.all_time_entries.first) }

      it 'should produce exactly 3 available slots' do
        expect(time_slots.count).to be 3
      end

      it 'should produce [9:00-9:15] first' do
        expect(time_slots.first.range.begin.hour).to be 9
        expect(time_slots.first.range.begin.minute).to be 0
        expect(time_slots.first.range.end.hour).to be 9
        expect(time_slots.first.range.end.minute).to be 15
      end

      it 'should produce [9:15-9:30] second' do
        expect(time_slots[1].range.begin.hour).to be 9
        expect(time_slots[1].range.begin.minute).to be 15
        expect(time_slots[1].range.end.hour).to be 9
        expect(time_slots[1].range.end.minute).to be 30
      end

      it 'should produce [9:45-10:00] last' do
        expect(time_slots.last.range.begin.hour).to be 9
        expect(time_slots.last.range.begin.minute).to be 45
        expect(time_slots.last.range.end.hour).to be 10
        expect(time_slots.last.range.end.minute).to be 0
      end

    end

    # Test the available Appointments returned by the API
    # Note: These are Available Appointments, not existing ones.
    describe '#available_on' do
      let(:appointments) { engine.available_on(DateTime.now) }

      it 'should have 2 appointments' do
        expect(appointments.count).to be 2
      end
    end
  end # END SCENARIO: 2


  #############################################
  # SCENARIO: 3
  context "Available TimeSlots with Many Appointment Collision" do
    let(:engine) {
      create_engine(
        service_duration: 15,
        services:       [10, 15, 20, 30], # minimum 10 minute TimeBlocks

        # TimeEntry   9:00-10:00 - 9 hour shift 36 slots
        time_entries:   [{ start_hour: 8, end_hour: 17, day: :now }],

        # Break       12:30-13:00 - 30 minute break - 2 slots
        break_entries:  [{ start_hour: 12, start_minute: 30, end_hour: 13, day: :now }],

        # Appointment - a bunch of 1 hour appointments
        appointments:   [
          { start_hour: 10, end_hour: 11 }, # 4 slots
          { start_hour: 13, end_hour: 14 }, # 4 slots
          { start_hour: 15, end_hour: 16 }, # 4 slots
        ])

      # Notes:
      # Expecting 22 free TimeBlocks:
      #   9 hours - 3 appointments - 0.5 break = 5.5 open hours
      #   5.5 hours / 15 minutes = 22 units
    }

    # Test the available TimeSlots returned by the API
    describe '#extract_available_slots' do
      let(:time_slots) { engine.extract_available_slots(engine.all_time_entries.first) }

      it 'should produce exactly 22 available slots' do
        expect(time_slots.count).to be 22
      end
    end

    # Test the available Appointments returned by the API
    # Note: These are Available Appointments, not existing ones.
    describe '#available_on' do
      let(:appointments) { engine.available_on(DateTime.now) }

      # Due to the amount of available time slots, we should always have
      # at least 3 available appointment responses.
      it 'should have at least 3 appointments' do
        expect(appointments.count).to be >= 3
      end
    end
  end # END SCENARIO: 2

end
