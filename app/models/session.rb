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
      sesh = false
      query = { customer_id: customer.id, business_id: business.id }

      existing = Session.where(query).first
      if existing
        sesh = existing
        SystemLog.fact(title: 'session_loaded', payload: "SESSION:#{sesh.id}")
      else
        sesh = Session.create! query
        SystemLog.fact(title: 'session_created', payload: "SESSION:#{sesh.id}")
      end

      # seshion is now ready for use!
      sesh
    end
  end


  private

end
