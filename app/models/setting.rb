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

  scope :business, ->(business) { where business_id: business.id }
  scope :key, ->(key) { where key: key }

  # Constants for various option names
  OFFICE_SELECTION_ASK             = 'office_ask'
  OFFICE_SELECTION_ASK_AND_ASSUME  = 'office_ask_and_assume'
  OFFICE_SELECTION_ASSUME          = 'office_assume'

  SERVICE_SELECTION_ASK            = 'service_ask'
  SERVICE_SELECTION_ASK_AND_ASSUME = 'service_ask_and_assume'
  SERVICE_SELECTION_ASSUME         = 'service_assume'

  USER_SELECTION_FULL_CONTROL = 'user_selection_full_control'
  USER_SELECTION_EXPRESS_I    = 'user_selection_express_1'
  USER_SELECTION_EXPRESS_II   = 'user_selection_express_2'
  USER_SELECTION_EXPRESS_III  = 'user_selection_express_3'

  USER_SELECTION_PRIORITY_RANDOM    = 'user_selection_priority_random'
  USER_SELECTION_PRIORITY_AUTOMATIC = 'user_selection_priority_automatic'

  # Constants for key lookup
  PRIORITY                = 'priority'
  USER_SELECTION          = 'user_selection'
  USER_SELECTION_PRIORITY = 'user_selection_priority'
  SERVICE_SELECTION       = 'service_selection'
  OFFICE_SELECTION        = 'office_selection'

  class << self
    def get_or_create(key, opts = {})
      existing = Setting.where(key: key, business_id: opts[:business_id]).first
      return existing if existing

      raise "business_id is required for first time generation" if opts[:business_id].nil?
      raise "value is required for first time generation" if opts[:value].nil? and opts[:default_value].nil?

      Setting.create(key: key, value: opts[:value] || opts[:default_value], business_id: opts[:business_id])
    end
  end

  def is(what)
    value == what
  end
  alias_attribute :is?, :is

  def to_b
    value.to_b
  end

  def office_selection_type=(type)
    self.key = OFFICE_SELECTION
    self.value = type
  end

  def service_selection_type=(type)
    self.key = SERVICE_SELECTION
    self.value = type
  end

  def user_selection_type=(type)
    self.key = USER_SELECTION
    self.value = type
  end

  def user_selection_priority_type=(type)
    self.key = PRIORITY
    self.value = type
  end

  def user_selection_full_control?
    value == USER_SELECTION_FULL_CONTROL
  end

end
