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
    "#{id} / #{name} — #{business.display_name}"
  end

  def update_ordering
    if business
      PrioritySorter.sort! Service.business(business)
    end
  end

end
