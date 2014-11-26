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

  after_save :update_remote_source

  def display_name
    org = (office and office.display_name) || sub_account.business.display_name
    "#{org} / #{phone_number}"
  end

  def update_remote_source
    Skej::Twilio.update_number(sid: sid,
                               sub_account_sid: sub_account.sid,
                               sms_url: sms_url, 
                               voice_url: voice_url, 
                               status_url: status_url,
                               friendly_name: friendly_name, 
                               sms_method: sms_method, 
                               voice_method: voice_method)
  end
end
