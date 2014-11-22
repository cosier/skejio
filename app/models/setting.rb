# == Schema Information
#
# Table name: settings
#
#  id               :integer          not null, primary key
#  business_id      :integer          not null
#  key              :string(255)      not null
#  value            :string(255)      not null
#  description      :text
#  is_active        :boolean          default(TRUE)
#  created_at       :datetime
#  updated_at       :datetime
#  supportable_id   :integer
#  supportable_type :string(255)
#

class Setting < ActiveRecord::Base
  belongs_to :business

  belongs_to :supportable, polymorphic: true

  validates_presence_of :key
  validates_presence_of :business
  validates_uniqueness_of :business_id, :scope => :key

  # Constants for various option names
  SERVICE_SELECTION_ASK = 'ask'
  SERVICE_SELECTION_ASK_AND_ASSUME = 'ask_and_assume'
  SERVICE_SELECTION_ASSUME = 'assume'

  USER_SELECTION_FULL_CONTROL = 'full_control'
  USER_SELECTION_EXPRESS_I = 'express_1'
  USER_SELECTION_EXPRESS_II = 'express_2'
  USER_SELECTION_EXPRESS_III = 'express_3'

  USER_PRIORITY_RANDOM = 'random'
  USER_PRIORITY_AUTOMATIC = 'automatic'
  USER_PRIORITY_CUSTOM = 'custom'

  # Constants for key lookup
  USER_PRIORITY = 'user_priority'
  USER_SELECTION = 'user_selection'
  SERVICE_SELECTION = 'service_selection'

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
    self.key = SERVICE_SELECTION
    self.value = type
  end

  def user_selection_type=(type)
    self.key = USER_SELECTION
    self.value = type
  end

  def user_priority_type=(type)
    self.key = USER_PRIORITY
    self.value = type
  end

end
