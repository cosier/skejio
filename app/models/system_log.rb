# == Schema Information
#
# Table name: system_logs
#
#  id            :integer          not null, primary key
#  parent_id     :integer
#  business_id   :integer
#  customer_id   :integer
#  session_id    :integer
#  session_tx_id :integer
#  log_type      :integer
#  from          :string(255)
#  to            :string(255)
#  meta          :text
#  created_at    :datetime
#  updated_at    :datetime
#

class SystemLog < ActiveRecord::Base
  belongs_to :business
  belongs_to :customer
  belongs_to :session

  has_many :facts

  class << self

    def fact(opts = {})
      log = RequestStore.store[:log]
      raise 'No SystemLog Found / Available for this Request' if log.nil?
      log.facts.create! opts
    end

    def current_log
      RequestStore.store[:log]
    end

  end

end
