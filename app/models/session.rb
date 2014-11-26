# == Schema Information
#
# Table name: sessions
#
#  id          :integer          not null, primary key
#  business_id :integer
#  customer_id :integer
#  created_at  :datetime
#  updated_at  :datetime
#

class Session < ActiveRecord::Base

  validates_uniqueness_of :customer_id, :scope => :business_id

  class << self
    def load(customer, business)
      Session.first_or_create(customer_id: customer.id, business_id: business.id)
    end
  end
end
