class Customer < ActiveRecord::Base
  has_many :system_logs
  has_many :sessions
end
