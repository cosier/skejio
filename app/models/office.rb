# == Schema Information
#
# Table name: offices
#
#  id                 :integer          not null, primary key
#  business_id        :integer          not null
#  name               :string(255)
#  location           :string(255)
#  created_at         :datetime
#  updated_at         :datetime
#  is_schedule_public :boolean          default(TRUE)
#  time_zone          :string(255)
#

class Office < ActiveRecord::Base
  belongs_to :business

  validates_presence_of :business
  validates_presence_of :name
  validates_presence_of :location

  scope :business, ->(business){ where business_id: business.id  }
end
