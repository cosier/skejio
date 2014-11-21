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

  belongs_to :supportable, polymorphic: true

  validates_presence_of :key
  validates_presence_of :business
  validates_uniqueness_of :business_id, :scope => :key

  # core settings accessors (for simple_form generation)
  attr_accessor :service_selection_type

  def get_or_create(key, opts = {})
    existing = Setting.where(key: key).first
    return existing if existing

    raise "business_id is required for first time generation" if opts[:business_id].nil?
    raise "value is required for first time generation" if opts[:value].nil?


    Setting.create(key: key, value: opts[:value], business_id: opts[:business_id])
  end

end
