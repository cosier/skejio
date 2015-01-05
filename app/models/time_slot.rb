class TimeSlot
  attr_reader :start_time
  attr_reader :end_time

  attr_reader :time_entry
  attr_accessor :session

  # Initialize the TimeSlot with the start & end values.
  # -:st: - Start Time DateTime object
  # -:et: - End Time DateTime object
  # -:te: - Time Entry which this TimeSlot is part of.
  def initialize(st, et, te = false)
    @start_time = st
    @end_time   = et
    @time_entry = te
  end

  # Returns the amount of minutes this TimeSlot covers.
  def duration
    ((end_time - start_time) * 24 * 60).to_f
  end

  def range
    start_time..end_time
  end

end
