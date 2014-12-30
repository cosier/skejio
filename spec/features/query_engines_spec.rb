require 'rails_helper'

feature "QueryEngine", :type => :feature do

  describe '#available_on' do

    let(:engine) {

      session = create_scheduler_session

      create_time_entries session.chosen_provider,
        [{ start_hour: 9, end_hour: 20, day: :wednesday }]

      create_breaks session.chosen_provider,
        [{ start_hour: 12, end_hour: 13, day: :wednesday }]

      Skej::Appointments::QueryEngine.new(session)
    }

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
end
