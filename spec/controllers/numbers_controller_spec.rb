require 'rails_helper'

describe NumbersController, :type => :controller do

  before :each do
    @number_unavailable = "+15005550000"
    @number_invalid = "+15005550001"
    @number_valid = "+15005550006"
  end

  context '#buy_number' do

    before do
      @user = create(:admin)
      sign_in(@user)

      search_numbers = Skej::Twilio.search_numbers

      @post_data = {
        business_id: @user.business.id,
        number: @number_valid
      }

      post :buy_number, @post_data
    end


    it 'does not blow up' do
      expect(response.status).to eq(200)
    end

  end #buy_number



end
