class TimeSheetService < ActiveRecord::Base
  belongs_to :service
  belongs_to :time_sheet
  belongs_to :business
end
