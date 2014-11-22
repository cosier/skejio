# == Schema Information
#
# Table name: numbers
#
#  id                 :integer          not null, primary key
#  sub_account_id     :integer
#  office_id          :integer
#  phone_number       :string(255)      not null
#  sid                :string(255)
#  created_at         :datetime
#  updated_at         :datetime
#  sms_url            :string(255)
#  voice_url          :string(255)
#  status_url         :string(255)
#  voice_fallback_url :string(255)
#  sms_fallback_url   :string(255)
#  friendly_name      :string(255)
#  capabilities       :integer
#  account_sid        :string(255)
#  voice_method       :string(255)
#  sms_method         :string(255)
#

class Number < ActiveRecord::Base
  belongs_to :sub_account
  belongs_to :office

  validates_presence_of :sub_account
  validates_presence_of :sid
end
