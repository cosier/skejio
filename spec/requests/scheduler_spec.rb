require 'rails_helper'

describe 'Scheduler', :type => :feature do

  let(:business){ create(:business) }

  before(:each) do
  end

  context 'SMS unregistered welcome' do
    get twilio_sms_path(scheduler_request)

    # turn the response body into an XML document for investigating
    doc = Nokogiri::XML(response.body)

    # Get the child of the first child, which is the children of the <Response>
    children = doc.children.first.children
    message = children.first.text.downcase

    expect(children.count).to be 1
    # Expect that the initial response is the Welcome message.
    expect(message.include? "welcome").to be true
    # Expect that the user registration has kicked in.
    expect(message.include? "full name").to be true
  end

end
