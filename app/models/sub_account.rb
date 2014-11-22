# == Schema Information
#
# Table name: sub_accounts
#
#  id            :integer          not null, primary key
#  business_id   :integer
#  friendly_name :string(255)
#  auth_token    :string(255)
#  sid           :string(255)
#  created_at    :datetime
#  updated_at    :datetime
#

class SubAccount < ActiveRecord::Base
  belongs_to :business
  has_many :numbers

  def search_numbers(search_params)
    Skej::Twilio.search_available_numbers(business, search_params)
  end

  def buy_number(number)
    response = Skej::Twilio.buy_number(business, number)
    numbers.create(
      sid: response.sid, 
      account_sid: response.account_sid,
      friendly_name: response.friendly_name,
      voice_method: response.voice_method,
      sms_method: response.sms_method,
      phone_number: response.phone_number, 
      status_url: response.status_callback,
      voice_url: response.voice_url,
      sms_url:   response.sms_url)
  end

end
