# == Schema Information
#
# Table name: offices
#
#  id          :integer          not null, primary key
#  business_id :integer          not null
#  name        :string(255)
#  location    :string(255)
#  created_at  :datetime
#  updated_at  :datetime
#

class Office < ActiveRecord::Base
  belongs_to :business

  validates_presence_of :business
  validates_presence_of :name
  validates_presence_of :location

end
