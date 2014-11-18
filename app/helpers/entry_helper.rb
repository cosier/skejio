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

  def convert_date_ranges(entry)
    entry = entry.dup
    entry[:valid_from_at] = Chronic.parse(entry[:valid_from_at]) if entry[:valid_from_at]
    entry[:valid_until_at] = Chronic.parse(entry[:valid_until_at]) if entry[:valid_until_at]
    entry
  end

end
