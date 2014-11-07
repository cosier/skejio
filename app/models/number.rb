# == Schema Information
#
# Table name: numbers
#
#  id             :integer          not null, primary key
#  sub_account_id :integer
#  office_id      :integer
#  number         :string(255)
#  sid            :string(255)
#  created_at     :datetime
#  updated_at     :datetime
#

class Number < ActiveRecord::Base
  belongs_to :sub_account
  belongs_to :office

  validates_presence_of :sub_account
  validates_presence_of :sid
end
