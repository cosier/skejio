# == Schema Information
#
# Table name: customers
#
#  id                 :integer          not null, primary key
#  phone_number       :string(255)
#  first_name         :string(255)
#  last_name          :string(255)
#  sms_verified       :boolean          default(FALSE)
#  voice_verified     :boolean          default(FALSE)
#  verification_code  :string(255)
#  created_at         :datetime
#  updated_at         :datetime
#  recording_name_url :string(255)
#

class Customer < ActiveRecord::Base

  has_many :system_logs,
    :dependent => :destroy
  has_many :scheduler_sessions

  validates_uniqueness_of :phone_number

  class << self

    # Get the customer entity for a given Phone Number.
    # While enforcing the uniqueness of the phone_number across Customer records.
    def load(number)
      customer = false
      query = { phone_number: number }

      existing = Customer.where(query).first
      if existing
        customer = existing
        SystemLog.fact(title: 'customer', payload: "loaded -> " + customer.display_name)
      else
        customer = Customer.create! query
        SystemLog.fact(title: 'customer', payload: "created -> " + customer.display_name)
      end

      customer

    end

  end

  # Normalise the two seperate fields (first and last names)
  # into a single string with fallbacks.
  def name
    name_sum = ""
    name_sum << first_name if first_name.present?
    name_sum << " " if first_name.present? and last_name.present?
    name_sum << last_name if last_name.present?
    name_sum << "Unknown(##{id})" if name_sum.empty?
    name_sum
  end

  # Formal name for this Entity
  def display_name
    "#{name} / #{phone_number}"
  end

  def has_name?
    recording_name_url || (first_name and last_name)
  end

end
