class Number < ActiveRecord::Base
  belongs_to :sub_account
  belongs_to :office
end
