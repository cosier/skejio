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
end
