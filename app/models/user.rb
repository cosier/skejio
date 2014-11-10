# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  business_id            :integer
#  email                  :string(255)      default(""), not null
#  encrypted_password     :string(255)      default(""), not null
#  first_name             :string(255)
#  last_name              :string(255)
#  roles                  :integer
#  status                 :integer
#  reset_password_token   :string(255)
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :inet
#  last_sign_in_ip        :inet
#  failed_attempts        :integer          default(0), not null
#  unlock_token           :string(255)
#  locked_at              :datetime
#  created_at             :datetime
#  updated_at             :datetime
#  phone                  :string(255)
#

class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
    :recoverable, :rememberable, :trackable, :validatable

  belongs_to :business

  validates_presence_of :first_name
  validates_presence_of :last_name
  validates_presence_of :phone

  scope :business, ->(business){ where business_id: business.id  }
  scope :service_providers, ->(){ with_roles(:service_provider)  }

  # Check the roles bitmask like this:
  # user.roles?(:admin)
  #
  # Only append keys to the list,
  # other wise users will need to be updated / cleaned.
  ROLES = [

    # Roles for business staff
    :admin,
    :service_provider,
    :schedule_manager,
    :schedule_viewer,
    :appointment_manager,
    :appointment_viewer,

    # Roles for super console permission
    :super_admin,
    :super_business_editor,
    :super_business_viewer,
  ]

  bitmask :roles, :as => ROLES

  # Similar to the roles bitmask, query with user.status?(:suspended)
  #
  # Only append keys to the list,
  # other wise users will need to be updated / cleaned.
  bitmask :status, :as => [
    :active,
    :suspended,
    :pending
  ]

  # Returns a formal name for the user.
  def display_name
    # Format the name components
    f = first_name and first_name.downcase.capitalize || ""
    l = last_name and last_name.downcase.capitalize || ""

    # put it together
    "#{f} #{l}"
  end

  def user_type
    roles.first.upcase || "Staff"
  end

end
