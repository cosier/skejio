# == Schema Information
#
# Table name: services
#
#  id          :integer          not null, primary key
#  business_id :integer          not null
#  name        :string(255)      not null
#  description :text
#  duration    :integer          default(60)
#  created_at  :datetime
#  updated_at  :datetime
#  is_public   :boolean          default(TRUE)
#  sort_order  :integer
#

class Service < ActiveRecord::Base
  include Sortable

  belongs_to :business

  # Allow a Setting(s) to reference a service (polymorphically)
  has_many :settings, as: :supportable

  scope :business, ->(business) { where business_id: business.id  }
  after_create :update_ordering

  def disabled?
    true
  end

  alias_method :disabled, :disabled?

  def display_name
    name.titleize
  end

  def update_ordering
    if business
      PrioritySorter.sort! Service.business(business)
    end
  end

end
