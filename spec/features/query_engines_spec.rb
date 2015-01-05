require 'rails_helper'

feature "QueryEngine", :type => :feature do

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


  # SCENARIO: 2
  context "Available TimeSlots with Basic Collisions" do
    let(:engine) {
      create_engine(
        service_duration: 15,
        services:       [10, 15, 20, 30], # minimum 10 minute TimeBlocks
        time_entries:   [{ start_hour: 9, end_hour: 10, day: :now }],
        break_entries:  [{ start_hour: 9, start_minute: 30, end_hour: 9, end_minute: 40, day: :now }],
        appointments:   [{ start_hour: 9, start_minute: 30, end_hour: 10 }])
    }

    describe '#extract_available_slots' do
      let(:results) { engine.extract_available_slots(engine.all_time_entries.first) }

      it 'should have 3 valid slots' do
        expect(results.count).to be 3
      end
    end

    describe '#available_on' do
      let(:results) { engine.available_on(DateTime.now) }

      it 'should have 3 appointments' do
        expect(results.count).to be 3
      end
    end
  end # END SCENARIO: 2

end
