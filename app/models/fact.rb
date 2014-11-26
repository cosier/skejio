# == Schema Information
#
# Table name: facts
#
#  id            :integer          not null, primary key
#  system_log_id :integer
#  title         :string(255)
#  type          :integer
#  payload       :text
#  created_at    :datetime
#  updated_at    :datetime
#

class Fact < ActiveRecord::Base
  belongs_to :system_log
  
  enum type: %w(response request transition)

end
