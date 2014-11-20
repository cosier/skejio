# == Schema Information
#
# Table name: settings
#
#  id          :integer          not null, primary key
#  business_id :integer          not null
#  key         :string(255)      not null
#  value       :string(255)      not null
#  description :text
#  is_active   :boolean          default(TRUE)
#  created_at  :datetime
#  updated_at  :datetime
#

class Setting < ActiveRecord::Base
  belongs_to :business
  validates_uniqueness_of :business_id, :scope => :key
end
