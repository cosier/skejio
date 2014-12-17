module Skej

  # Travel and warping of time objects
  module Warp

    # Return a DateTime that has it's time_zone altered
    # in place to the specified time_zone.
    def self.offset(datetime, offset)
      datetime.to_datetime.strftime("%Y-%m-%d %H:%M:%S #{offset}").to_datetime
    end

  end
end
