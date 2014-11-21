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

  class << self
    def get_or_create(key, opts = {})
      existing = Setting.where(key: key).first
      return existing if existing

      raise "business_id is required for first time generation" if opts[:business_id].nil?
      raise "value is required for first time generation" if opts[:value].nil? and opts[:default_value].nil?

      Setting.create(key: key, value: opts[:value] || opts[:default_value], business_id: opts[:business_id])
    end
  end

  def is(what)
    value == what
  end

  def to_b
    value.to_b
  end

  def service_selection_type=(type)
    self.key = 'service_selection'
    self.value = type
  end

end
