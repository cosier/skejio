# == Schema Information
#
# Table name: businesses
#
#  id              :integer          not null, primary key
#  name            :string(255)      not null
#  slug            :string(255)      not null
#  description     :text
#  billing_name    :string(255)
#  billing_phone   :string(255)
#  billing_email   :string(255)
#  billing_address :text
#  is_listed       :boolean          default(TRUE)
#  is_active       :boolean          default(TRUE)
#  created_at      :datetime
#  updated_at      :datetime
#

class Business < ActiveRecord::Base

  has_many :users,
    dependent: :destroy

  has_many :offices,
    dependent: :destroy

  has_many :settings,
    dependent: :destroy

  has_many :services,
    dependent: :destroy

  has_many :sub_accounts
  has_many :numbers,
    :through => :sub_accounts

  #validates_uniqueness_of :slug
  validates_presence_of :slug

  before_validation :ensure_unique_slug

  after_save :check_for_approval_processing

  def available_offices
    offices.where(is_schedule_public: true)
  end

  def available_services
    services.where(is_public: true)
  end

  def available_providers
    users.provider
  end

  alias_attribute :service_providers, :available_providers

  # Formal display name for this entity
  def display_name
    name and name.downcase.titleize
  end

  # Welcome emails are sent at registration,
  # which means there is usually only 1 user available.
  def send_welcome_email
    users.each do |user|
      message = BusinessMailer.welcome_introduction(user)
      message.deliver
    end
  end

  # At this moment we will only have one sub account per business.
  def sub_account
    sub_accounts.first
  end

  def ensure_unique_slug
    # Don't mess with the slug if it's already defined manually.
    return true if slug.present?

    # slugify the name into something neat and tidy.
    slg = name.parameterize

    # Check for a previous entry,
    # If found, append a random number
    if Business.where(slug: slg).first
      # Unique enough for our purposes
      slg = "#{slg}-#{Random.rand(99999..999999)}"
    end

    self.slug = slg
  end

  def settings(opts = {})
    opts.each do |k,v|
      if v.kind_of? String
        val = v
      else
        raise "Unsupported value type: #{v.class.name}"
      end
      Setting.create! key: k, value: val, business_id: id
    end

    # Return self for chaining
    self
  end

  def setting(key)
    result = Setting.business(self).key(key)
    return result if result.present?

    raise "Unknown Setting Key: #{key}" unless Setting.valid_key? key

    Setting.create_default(key: key, business: self)
  end

  private

  def check_for_approval_processing
    # Don't run this hook in TEST env due to  Twilio credential restrictions
    if is_active? and sub_accounts.empty? and not Rails.env.test?
      response = Skej::Twilio.create_sub_account(self)
      sub_accounts.create(
        :business_id   => self.id,
        :sid           => response.sid,
        :auth_token    => response.auth_token,
        :friendly_name => response.friendly_name)
    end
  end
end
