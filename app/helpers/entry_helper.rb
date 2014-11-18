module EntryHelper
  def convert_meridians(entry)
    entry = entry.dup
    # convert meridians into 24 time
    if entry[:start_meridian] and entry[:start_meridian].downcase == "pm"
      entry[:start_hour] = entry[:start_hour].to_i + 12
    end

    if entry[:end_meridian] and entry[:end_meridian].downcase == "pm"
      entry[:end_hour] = entry[:end_hour].to_i + 12
    end

    entry.except(:start_meridian, :end_meridian)
  end

end
