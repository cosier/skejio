module AppointmentSupport

  def create_scheduler_session(opts = {})
      @session = session = create(:scheduler_session)
      business = session.business

      office   = opts[:office] || business.offices.first
      service  = opts[:service] || business.services.first
      provider = opts[:provider] || business.service_providers.first

      session.store! :chosen_office_id, office.id
      session.store! :chosen_service_id, service.id
      session.store! :chosen_provider_id, provider.id

      create_schedule_rule(business_id: business.id, service_provider_id: provider.id)
      session
  end

  def create_schedule_rule(opts = {})
    @schedule_rule = create(:schedule_rule, opts)
    @time_sheet    = create(:time_sheet, schedule_rule_id: @schedule_rule.id, business_id: session.business_id)

    return @schedule_rule
  end

  def create_engine(opts = {})
    session = create_scheduler_session

    # Allow customisation of the Service duration,
    # and consequently the size of all TimeBlock(s) calculations.
    if opts[:service_duration].present?
      session.chosen_service.update! duration: opts[:service_duration]
    end

    create_time_entries session.chosen_provider, opts[:time_entries]
    create_breaks session.chosen_provider, opts[:break_entries]
    Skej::Appointments::QueryEngine.new(session)
  end


  def create_time_entries(provider, entries)

    entries.each do |entry|
      start_hour = (entry[:start_hour] || Random.rand(1..10).hours).to_i
      end_hour   = (entry[:end_hour]   || time_start + Random.rand(1..10)).to_i
      enabled    = (entry.key? :is_enabled) ? entry[:is_enabled] : true

      if session.chosen_provider.present?
        provider_id = (entry.key? :provider_id) ? entry[:provider_id] : session.chosen_provider.id
      end

      office_id   = (entry.key? :office_id) ? entry[:office_id] : session.chosen_office.id
      service_id   = (entry.key? :service_id) ? entry[:service_id] : session.chosen_service.id

      day = Skej::NLP.parse(session, entry[:day].to_s).strftime('%A').downcase.to_sym
      entry.delete :day

      params = entry.reverse_merge provider_id: provider_id,
                                   business_id: session.business_id,
                                   time_sheet_id: @time_sheet.id,
                                   service_id: service_id,
                                   office_id: office_id,
                                   start_hour: start_hour,
                                   end_hour: end_hour,
                                   end_minute: entry[:end_minute] || 0,
                                   start_minute: entry[:start_minute] || 0,
                                   is_enabled: enabled,
                                   day: day

      TimeEntry.create! params
    end
  end

  def create_breaks(provider, breaks)
    breaks.each do |entry|
      start_hour = (entry[:start_hour] || Random.rand(1..10).hours).to_i
      end_hour   = (entry[:end_hour]   || time_start + Random.rand(1..10)).to_i
      enabled    = entry.key? :is_enabled ? entry[:is_enabled] : true

      provider_id = entry.key? :provider_id ? entry[:provider_id] : session.chosen_provider.id
      office_id   = entry.key? :office_id ? entry[:office_id] : session.chosen_office.id

      float = entry.key? :float ? entry[:float].to_i : 0

      day = Skej::NLP.parse(session, entry[:day].to_s).strftime('%A').downcase.to_sym
      entry.delete :day

      params = entry.reverse_merge provider_id: provider_id,
                                   schedule_rule_id: @schedule_rule.id,
                                   business_id: session.business_id,
                                   office_id: office_id,
                                   start_hour: start_hour,
                                   end_hour: end_hour,
                                   end_minute: entry[:end_minute] || 0,
                                   start_minute: entry[:start_minute] || 0,
                                   floating_break: float,
                                   is_enabled: enabled,
                                   day: day


      BreakShift.create! params
    end
  end

  def session
    @session
  end

end
