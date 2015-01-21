require 'rails_helper'

RSpec.describe "SchedulerStateMachines", :type => :request do
  describe "GET /scheduler_state_machines" do
    let(:business) { create(:business) }

    it "unregistered users" do
      get twilio_sms_path(scheduler_request)

      # Expect that the initial response is the Welcome message.
      expect(message.include? "welcome").to be true
      # Expect that the user registration has kicked in.
      expect(message.include? "full name").to be true
    end

    it "registered user" do
      scheduler_register_customer!
      get twilio_sms_path(scheduler_request)
      expect(message.include? "full name").to be false
    end

  end
end
