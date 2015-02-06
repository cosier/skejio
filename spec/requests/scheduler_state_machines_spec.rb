require 'rails_helper'

RSpec.describe 'SchedulerStateMachines', :type => :request do

  let(:business) { 
    create(:business).settings({ 
      service_selection: 'service_ask_and_assume',
      office_selection: 'office_ask_and_assume',
      user_selection: 'user_selection_full_control'
    })
  }

  describe '/sms/unregistered' do
    # let(:business) { create(:business) }
    it 'unregistered users' do
      Customer.destroy_all
      sms 'hello!'
      binding.pry

      # Expect that the initial response is the Welcome message.
      expect(message.include? 'welcome').to be true
      # Expect that the user registration has kicked in.
      expect(message.include? 'full name').to be true
    end
  end

  describe '/sms/registered without appointments' do

    # Ensure each run has the customer registered
    before(:each) { scheduler_register_customer! }

    it 'asks for a date input' do
      sms 'hello!'
      expect(message.include? 'when would you like your next').to be true
    end

    it 'accepts dictation' do
      sms 'tomorrow'
      expect(message.include? 'sorry, we did not find any').to be true
    end 
  end

  describe '/sms/registered with appointments' do
    before(:each) {

    }
  end

end
