require 'rails_helper'

RSpec.describe 'SchedulerStateMachines', :type => :request do

  before(:all) {
    @business = create(:business).settings({
      service_selection: 'service_ask',
      office_selection:  'office_ask',
      user_selection:    'user_selection_full_control'
    })
  }

  let(:business) { @business }

  describe '/sms/unregistered' do
    # let(:business) { create(:business) }
    it 'unregistered users' do
      sms 'hello!'

      # Expect that the initial response is the Welcome message.
      expect(message.include? 'welcome').to be true
      # Expect that the user registration has kicked in.
      expect(message.include? 'full name').to be true
    end
  end

  describe '/sms/registered without time schedules' do

    # Ensure each run has the customer registered
    before(:each) { scheduler_register_customer! }

    it 'asks for a date input' do
      sms 'hello!'
      expect(message.include? 'when would you like your next').to be true
    end

    it 'accepts dictation' do
      sms 'tomorrow'
      # Should be no results as we have not setup any time schedules
      expect(message.include? 'sorry, we did not find any').to be true
    end
  end

  describe '/sms/registered with time schedules' do

    before(:each) { scheduler_register_customer! }

    # Bootstrap the Scheduler Engine and it's dependencies.
    before(:all) {
      bootstrap(
        # Make sure we pass in the existing business to avoid biz duplication.
        business: @business,
        service_duration: 60, # 60 minute blocks
        services: [60, 120],
        time_entries: [{ start_hour: 9, end_hour: 15, day: :tomorrow }],
        break_entries: [{ start_hour: 12, end_hour: 13, day: :tomorrow }])
    }


    it 'should ask for service selection' do
      sms :tomorrow
      expect(message.include? 'please select a service').to be true
    end

    it 'should show available appointments' do
      sms :tomorrow
      sms 1 # Choose service

      # Interrogate appointment results
      expect(message.include? 'showing available appointments').to be true
    end
  end

end
