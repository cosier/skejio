require 'rails_helper'

describe NumbersController, :type => :controller do

  before :each do
    #@number_unavailable = "+15005550000"
    #@number_invalid = "+15005550001"
    #@number_valid = "+15005550006"
  end

  #context '#buy_number' do

    #before do
      #@user = create(:admin)
      #sign_in(@user)

      #search_params = { contains: 1 }
      #search_numbers = Skej::Twilio.search_available_numbers(@user.business, search_params)

      #@post_data = {
        #business_id: @user.business.id,
        #number: search_numbers.first.phone_number,
        #format: "json"
      #}

      #xhr :post, :buy_number, @post_data
    #end


    #it 'does not blow up' do
      #expect(response.status).to eq(200)
    #end

    #it "was successful" do
      #expect( JSON.parse(response.body)["success"] ).to_be true
    #end

    #it "created a number with an ID" do
      #expect( JSON.parse(response.body)["number"]["id"] ).to be > 0
    #end


  #end #buy_number



end
