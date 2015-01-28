require 'rails_helper'

feature 'Scheduler', type: :request do

  before(:each) do 
    # Ensure our customer is registered first
    scheduler_register_customer!
    ensure_session_loaded!
  end

  #############################################################################
  # First message sent by an unregistered Customer.
  #
  scenario 'SMS unregistered Customer' do
    sms 'Hello World'

    # Expect that the initial response is the Welcome message.
    expect(message.include? "welcome").to be true
    # Expect that the user registration has kicked in within the same txt.
    expect(message.include? "full name").to be true
  end

  #############################################################################
  # First message sent by a registered Customer.
  #
  scenario 'SMS registered Customer' do
    # Ensure our customer is registered first
    scheduler_register_customer!
    sms msg: 'hi, I would like an appointment please!'
    
    expect(message.start_with? 'when would you like').to be true
  end

  #############################################################################
  # After receiving a direct prompt for a date, the customer will send his
  # chosen date.
  scenario 'SMS registered Customer chooses a date after system prompt' do

    sms msg: 'hello!'
    sms msg: 'tomorrow'
  
    tomorrow = Skej::NLP.parse session, 'tomorrow'
    binding.pry

    expect(message.include? 'tomorrow').to be true
  end

  #############################################################################
  # Customer starts off the interaction with a date dictation.
  # chosen date.
  scenario 'SMS registered Customer chooses a date after system prompt' do
    # Ensure our customer is registered first
    scheduler_register_customer!

  end


end
