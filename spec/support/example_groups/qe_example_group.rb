module QEExampleGroup
  extend BaseExampleGroup

  RSpec.configure do |config|
    config.include self,
      :type => :request,
      :file_path => %r(spec/requests)
  end

  def create_customer(opts = {})
    @customer = create(:customer, opts)
  end

  def create_scheduler_session(opts = {})
      @customer = create_customer(opts[:customer])

      @session  = create(:scheduler_session, customer_id: @customer.id)
      @business = @session.business

      @office   = opts[:office] || @business.offices.first
      @service  = opts[:service] || @business.services.first
      @provider = opts[:provider] || @business.service_providers.first

      @session.store! :chosen_office_id, @office.id
      @session.store! :chosen_service_id, @service.id
      @session.store! :chosen_provider_id, @provider.id

      create_schedule_rule(
        business_id: @business.id,
        service_provider_id: @provider.id)

      @session
  end

  def create_schedule_rule(opts = {})
    @schedule_rule = create(:schedule_rule, opts)
    @time_sheet    = create(:time_sheet,
                            schedule_rule_id: @schedule_rule.id,
                            business_id: session.business_id)

    @schedule_rule
  end

  def create_engine(opts = {})
    session = create_scheduler_session

    duration = opts[:service_duration] || opts[:service_duration] || opts[:service]

    # Allow customisation of the Service duration,
    # and consequently the size of all TimeBlock(s) calculations.
    if duration.present?
      session.chosen_service.update!(duration: duration)
    end

    # Add additional services based on provided service durations
    opts[:services].map { |mins|
      session.business.services.create!(
        duration: mins,
        name: Faker::Internet.domain_word)
    } if opts[:services].present?

    create_time_entries session.chosen_provider, opts[:time_entries]
    create_breaks session.chosen_provider, opts[:break_entries]
    create_appointments opts[:appointments]

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

      office_id   = (entry.key? :office_id)  ? entry[:office_id]  : session.chosen_office.id
      service_id  = (entry.key? :service_id) ? entry[:service_id] : session.chosen_service.id

      day_target = entry[:day] || :midnight
      day = Skej::NLP.parse(session, day_target.to_s)
                     .strftime('%A')
                     .downcase
                     .to_sym

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

  def create_appointments(appointments)
    return if appointments.nil?

    # Appointment Parameters:
    #
    # -:start_hour:
    # -:start_minute:
    # -:end_hour:
    # -:end_minute:
    appointments.each do |a|
      opts = a.reverse_merge( start_hour: 1,
                              start_minute: 0,
                              end_hour: a[:start_hour] || 1,
                              end_minute: 0 )

      Appointment.create! create_appointment_option(opts)
    end

  end

  def apt_expect!(apt, conds)
    # Container for all the misses
    m = []

    # Get the time objects to match against
    st = apt.start_time
    et = apt.end_time

    # Conditions to match against the time object
    sh = conds[0] || 01
    sm = conds[1] || 00
    eh = conds[2] || 01
    em = conds[3] || 00

    # Record the mismatches into the misses container
    if st.present?
      m << "start hour:#{st.hour} > expected:#{sh}"  unless st.hour == sh
      m << "start min:#{st.minute} > expected:#{sm}" unless st.minute == sm
    end

    if et.present?
      m << "end hour:#{et.hour} > expected:#{eh}"  unless et.hour == eh
      m << "end min:#{et.minute} > expected:#{em}" unless et.minute == em
    end

    # Abort on any found mismatches
    raise """Invalid Appointment Matches:\n\n#{m.join("\n")}""" unless m.empty?

    # Ensure we only return true for present mismatches, even though we raise.
    #expect(m.present?).to be false
  end

  def create_appointment_option(opts)
    appointment = {
      business_id: @session.business_id,
      office_id: @office.id,
      customer_id: @customer.id,
      service_id: @service.id,
      service_provider_id: @provider.id,
      created_by_session_id: @session.id,
      start_time: appointment_time( opts[:start_hour],
                                    opts[:start_minute],
                                    opts[:day]),

      end_time:   appointment_time( opts[:end_hour],
                                    opts[:end_minute],
                                    opts[:day])
    }

    appointment
  end

  def appointment_time(hour, minute, day = :midnight)
    # Provide a default, if nil gets passed in
    day = :today unless day.present?

    # Use session away parsing of the day
    date = Skej::NLP.parse(@session, day.to_s)

    # Convert the datetime in a readable Day of the Week
    day = date.strftime('%A').downcase.to_sym

    # Update the NLP datetime to have the correct time for this appointment.
    date.change(hour: hour, min: minute)
  end

  def create_breaks(provider, breaks)
    return if breaks.nil?

    breaks.each do |entry|
      start_hour = (entry[:start_hour] || Random.rand(1..10).hours).to_i
      end_hour   = (entry[:end_hour]   || time_start + Random.rand(1..10)).to_i
      enabled    = entry.key?(:is_enabled) ? entry[:is_enabled] : true

      provider_id = entry.key?(:provider_id) ? entry[:provider_id] : session.chosen_provider.id
      office_id   = entry.key?(:office_id)  ? entry[:office_id]   : session.chosen_office.id

      float = entry[:float] || 0
      entry.delete :float

      day = Skej::NLP.parse(session, entry[:day].to_s)
                     .strftime('%A')
                     .downcase.to_sym

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
