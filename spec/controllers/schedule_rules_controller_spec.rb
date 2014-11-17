require 'rails_helper'

describe ScheduleRulesController, :type => :controller do

  before :each do
  end

  context '#create' do

    before do
      @user = create(:admin)
      sign_in(@user)

      @post_data = {
        business_id: @user.business.id,
        schedule_rule: {
          service_provider_id: @user.id,
          sheets: [
            {
              valid_from: "Now",
              valid_until: "Forever",
              services: nil,
              entries: gen_entries(count: 15)
            }
          ],
          breaks: gen_entries(count: 15)
        }
      }

      post :create, @post_data
    end


    it 'does not blow up' do
      expect(response.status).to eq(200)
    end

    it 'saves 15 BreakShifts onto the ScheduleRule' do
      expect(assigns(:schedule_rule).break_shifts.length).to eq(15)
      expect(assigns(:schedule_rule).break_shifts.select(&:persisted?).length).to eq(15)
    end

    it 'saves 15 TimeEntries onto the ScheduleRule' do
      expect(assigns(:schedule_rule).time_entries.length).to eq(15)
      expect(assigns(:schedule_rule).time_entries.select(&:persisted?).length).to eq(15)
    end

    it 'doesn\'t set validity dates when using natural text' do
      expect(assigns(:schedule_rule).time_sheets.first.valid_from_at).to eq(nil)
      expect(assigns(:schedule_rule).time_sheets.first.valid_until_at).to eq(nil)
    end

    it 'saves the ScheduleRule' do
      expect(assigns(:schedule_rule)).to be_persisted
    end

  end #create



end
