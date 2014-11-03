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
#  roles_mask             :integer
#  status_mask            :integer
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
#

class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  belongs_to :business

  # Check the roles bitmask like this:
  # user.roles?(:admin)
  bitmask :roles, :as => [
    :admin,
    :service_provider,

    :schedule_manager,
    :schedule_viewer,

    :appointment_viewer,
    :appointment_manager
  ]

  # Similar to the roles bitmask, query with user.status?(:suspended)
  bitmask :status, :as => [:active, :suspended, :pending]


  def display_name
    f = first_name.downcase.capitalize
    l = last_name.downcase.capitalize
    "#{f} #{l}"
  end

end
