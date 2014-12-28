# == Schema Information
#
# Table name: time_blocks
#
#  id            :integer          not null, primary key
#  time_entry_id :integer
#  business_id   :integer
#  time_sheet_id :integer
#  office_id     :integer
#  provider_id   :integer
#  day           :integer
#  created_at    :datetime
#  updated_at    :datetime
#  start_time    :datetime
#  end_time      :datetime
#

require 'test_helper'

class TimeBlockTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
