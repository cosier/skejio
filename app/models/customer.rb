# == Schema Information
#
# Table name: customers
#
#  id                :integer          not null, primary key
#  phone_number      :string(255)
#  first_name        :string(255)
#  last_name         :string(255)
#  sms_verified      :boolean          default(FALSE)
#  voice_verified    :boolean          default(FALSE)
#  verification_code :string(255)
#  created_at        :datetime
#  updated_at        :datetime
#

class Customer < ActiveRecord::Base
  has_many :system_logs
  has_many :sessions
  
  validates_uniqueness_of :phone_number

  class << self
    def load(number)
      Customer.first_or_create(phone_number: number)
    end
  end
end
