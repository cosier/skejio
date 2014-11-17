module ScheduleRulesSpecHelper

  def gen_entries(opts = {})
    opts.reverse_merge! count: 10, office_id: nil
    entries = []

    opts[:count].times do
      entries << {
        day: "monday",
        start_hour: Random.rand(1..10),
        start_minute: Random.rand(1..59),
        start_meridian: "AM",
        end_hour: Random.rand(1..11),
        end_minute: Random.rand(0..59),
        end_meridian: "PM",
        office_id: opts[:office_id]
      }
    end

    entries

  end

end
