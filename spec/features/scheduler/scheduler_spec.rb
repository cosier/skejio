require 'rails_helper'

feature 'Scheduler', :type => :feature do

  scenario 'SMS unregistered welcome' do
    visit twilio_sms_path(scheduler_request)

    # Expect that the initial response is the Welcome message.
    expect(message.include? "welcome").to be true
    # Expect that the user registration has kicked in.
    expect(message.include? "full name").to be true
  end

  scenario 'registered customer' do
    # Ensure our customer is registered first
    scheduler_register_customer!
    visit twilio_sms_path(scheduler_request)

    expect(message.start_with? "when would you like").to be true
  end



end
