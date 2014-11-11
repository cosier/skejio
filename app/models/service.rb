# == Schema Information
#
# Table name: services
#
#  id          :integer          not null, primary key
#  business_id :integer          not null
#  name        :string(255)      not null
#  description :text
#  priority    :integer          default(1)
#  duration    :integer          default(60)
#  created_at  :datetime
#  updated_at  :datetime
#

class Service < ActiveRecord::Base
  belongs_to :business
  scope :business, ->(business){ where business_id: business.id  }

  def disabled?
    true
  end

  alias_method :disabled, :disabled?
end
