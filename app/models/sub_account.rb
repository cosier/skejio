# == Schema Information
#
# Table name: sub_accounts
#
#  id          :integer          not null, primary key
#  business_id :integer
#  auth_token  :string(255)
#  sid         :string(255)
#  created_at  :datetime
#  updated_at  :datetime
#

class SubAccount < ActiveRecord::Base
  belongs_to :business
  has_many :numbers

  def search_numbers(search_params)
    Skej::Twilio.search_available_numbers(business, search_params)
  end

  def buy_number(number)
    response = Skej::Twilio.buy_number(business, number)
    numbers.create(sid: response[:sid], number: response[:number])
  end

end
