# == Schema Information
#
# Table name: offices
#
#  id                 :integer          not null, primary key
#  business_id        :integer          not null
#  name               :string(255)
#  location           :string(255)
#  created_at         :datetime
#  updated_at         :datetime
#  is_schedule_public :boolean          default(TRUE)
#  time_zone          :string(255)
#  sort_order         :integer
#

class Office < ActiveRecord::Base
  include Sortable

  belongs_to :business

  validates_presence_of :business
  validates_presence_of :name
  validates_presence_of :location

  scope :business, ->(business){ where business_id: business.id  }
  after_create :update_ordering

  def display_name
    "#{business.display_name} - #{name}"
  end

  def update_ordering
    if business
      PrioritySorter.sort! Office.business(business)
    end
  end

  def time_zone_offset
    require 'timezone_parser'
    match = TimezoneParser::getTimezones(time_zone)
      # Filter out any occurrences of "etc"
      .select { |t| t.downcase.include? "etc" ? false : true }
      # Use the first result
      .first

    log "parsing time_zone_offset: #{time_zone} -> #{match}"
    match
  end

end
