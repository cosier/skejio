require 'rails_helper'

describe ScheduleRulesController, :type => :controller do

  context '#create' do

    before(:each) do
      @user = login_admin

      @post_data = {
        format: 'json',
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

      url = create_business_schedule_rules_path(@user.business)
      go :post, url, @post_data
    end

    let(:schedule_rule) {
      ScheduleRule.last
    }


    it 'does not blow up' do
      # We should have a successful HTTP CREATE (201) status code.
      expect(session.response.status).to eq(201)
    end

    it 'saves 15 BreakShifts onto the ScheduleRule' do
      expect(schedule_rule.break_shifts.length).to eq(15)
      expect(schedule_rule.break_shifts.select(&:persisted?).length).to eq(15)
    end

    it 'saves 15 TimeEntries onto the ScheduleRule' do
      expect(schedule_rule.time_entries.length).to eq(15)
      expect(schedule_rule.time_entries.select(&:persisted?).length).to eq(15)
    end

    it 'doesn\'t set validity dates when using natural text' do
      expect(schedule_rule.time_sheets.first.valid_from_at).to eq(nil)
      expect(schedule_rule.time_sheets.first.valid_until_at).to eq(nil)
    end

    it 'saves the ScheduleRule' do
      expect(schedule_rule).to be_persisted
    end

  end #create



end
