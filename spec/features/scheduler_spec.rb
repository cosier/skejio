require 'rails_helper'

feature 'Scheduler', :type => :feature do

  scenario 'SMS unregistered welcome' do
    get twilio_sms_path(scheduler_request)

    # Expect that the initial response is the Welcome message.
    expect(message.include? "welcome").to be true
    # Expect that the user registration has kicked in.
    expect(message.include? "full name").to be true
  end

  scenario 'registered customer' do
    binding.pry
    # Ensure our customer is registered first
    scheduler_register_customer!

    get twilio_sms_path(scheduler_request)

    it 'should show an appointment menu upon successful dictation' do
      expect(message.include? "success").to be true
    end

  end



end
