require 'rails_helper'

feature "QueryEngine", :type => :feature do

  context "Scenario 1 - Basic 3 Appointment Results" do
    let(:engine) {
      create_engine(
        service_duration: 60, # 60 minute blocks
        time_entries: [{ start_hour: 9, end_hour: 15, day: :now }],
        break_entries: [{ start_hour: 12, end_hour: 13, day: :now }])
    }

    describe '#available_on' do
      context "Using the current time as input — (basic query operations)" do
        let(:results) { engine.available_on DateTime.now }

        it 'returns 3 appointments' do
          expect(results.length).to be 3
        end

        it 'should contain only Appointment members' do
          results.each { |result| expect(result).to be_a Appointment  }
        end
      end
    end

  end # Context - Scenario 1 END


  context "Scenario 2 - Limited Results" do
    let(:engine) {
      create_engine(
        service_duration: 60, # 60 minute blocks
        time_entries: [{ start_hour: 9, end_hour: 10, day: :now }],
        break_entries: [{ start_hour: 12, end_hour: 13, day: :now }])}

    describe '#valid_blocks' do
      let(:results) { engine.valid_blocks :now  }
      it 'should only have one valid block' do
        expect(results.count).to be 1
      end
    end
  end # Context - Scenario 2 END

  context "Scenario 3 - Mini TimeBlock(s)" do
    let(:engine) {
      create_engine(
        service_duration: 10, # 60 minute blocks
        time_entries: [{ start_hour: 9, end_hour: 10, day: :now }],
        break_entries: [{ start_hour: 12, end_hour: 13, day: :now }])}

    describe '#valid_blocks' do
      let(:results) { engine.valid_blocks :now  }
      it 'should have 1 hours worth of individual blocks' do
        # Since we have a :service_duration of 10 minutes,
        # we are expecting back 6 valid TimeBlocks.
        expect(results.count).to be 6
      end
    end
  end # Context - Scenario 3 END

  context "Scenario 4 - Mini TimeBlock(s) with break collision" do
    let(:engine) {
      create_engine(
        service_duration: 10, # 10 minute TimeBlocks
        time_entries:  [{ start_hour: 9, end_hour: 9, end_minute: 10, day: :now }],
        break_entries: [{ start_hour: 9, end_hour: 9, end_minute: 10, day: :now }])}

    describe '#valid_blocks' do
      let(:results) { engine.valid_blocks :now  }
      it 'should have collide with the break' do
        # Since we have a :service_duration of 10 minutes,
        # but have 1 break collision.
        # We are expecting back 5 valid TimeBlocks.
        expect(results.count).to be 0
      end
    end
  end # Context - Scenario 4 END


end
