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
  has_many :users

  validates_uniqueness_of :slug
  accepts_nested_attributes_for :users, :reject_if => :all_blank


  # Checks whether the given user is a member of this Businesses staffing.
  # Of course, a super_admin will pass as well.
  def valid_staff? (current_user)
    users.where({id: current_user.id}).first || current_user.roles?(:super_admin)
  end

end
