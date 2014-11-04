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
    dependent: :destroy,
    class_name: 'BusinessOffice'

  validates_uniqueness_of :slug
  validates_presence_of :slug

  before_validation :ensure_unique_slug

  # Checks whether the given user is a member of this Businesses staffing.
  # Of course, a super_admin will pass as well.
  def valid_staff? (current_user)
    users.where({id: current_user.id}).first || current_user.roles?(:super_admin)
  end

  # Formal display name for this entity
  def display_name
    name and name.downcase.capitalize
  end

  # Welcome emails are sent at registration,
  # which means there is usually only 1 user available.
  def send_welcome_email
    users.each do |user|
      message = BusinessMailer.welcome_introduction(user)
      message.deliver
    end
  end

  private

  def ensure_unique_slug
    # Don't mess with the slug if it's already defined manually.
    return true if slug.present?

    # slugify the name into something neat and tidy.
    s = name.parameterize

    # Check for a previous entry,
    # If found, append a random number
    if Business.where(slug: s).first
      # Unique enough for our purposes
      s = "#{s}-#{Random.rand(9999)}"
    end

    self.slug = s
  end

end
