class Scplanner.Models.Break extends Backbone.Model
  paramRoot: 'break_shift'

  defaults: {}

  constructor: (options)->
    super(options)

    if not sm = @get('start_meridian')
      if @hour('start') > 12
        @set 'start_meridian', 'pm'
        @set 'start_hour', @hour('start') - 12
      else
        @set 'start_meridian', 'am'

    if not em = @get('end_meridian')
      if @hour('end') > 12
        @set 'end_meridian', 'pm'
        @set 'end_hour', @hour('end') - 12
      else
        @set 'end_meridian', 'am'

  preload: ->
    if @id
      service_matches = Scp.Preload.break_services.where(break_shift_id: parseInt(@id))

      if service_matches.length > 0
        ids = []
        for service in service_matches
          ids << serice.id
        @set 'services', ids

  pretty: (key)->
    v = parseInt(@get(key))
    if v < 10
      v = "0#{v}"
    v

  floating_break: ->
    f = parseInt(@get 'floating_break')
    if f and f > 0
      return "#{f}min"
    else
      '- -'

  hour: (type)->
    parseInt @get("#{type}_hour")

  minute: (type)->
    parseInt @get("#{type}_minute")

  offices: ->
    ids = @get('offices')
    all_model = new Scp.Co.Offices.model
      name: 'All Offices'

    if ids.length == 0
      return [all_model]

    if ids.length == Scp.Co.Offices.length
      return [all_model]

    co = []
    for id in ids
      co.push Scp.Co.Offices.findWhere
        id: parseInt(id)

    co

  duration: ->
    mins = 0
    start_hour = parseInt @get('start_hour')
    start_min  = parseInt @get('start_minute')
    end_hour   = parseInt @get('end_hour')
    end_min    = parseInt @get('end_minute')

    start_pm = (@get('start_meridian').toLowerCase() == 'pm') ? true : false
    end_pm = (@get('end_meridian').toLowerCase() == 'pm') ? true : false

    if end_hour == 12 and not end_pm
      end_hour = 0

    start_hour = start_hour + 12 if start_pm
    end_hour   = end_hour   + 12 if end_pm and end_hour < 12

    if start_hour <= end_hour
      console.debug 'start_hour < end_hour', start_hour, end_hour
      mins = (end_hour * 60) - (start_hour * 60)
    else
      console.debug 'start_hour > end_hour', start_hour, end_hour
      mins = (end_hour * 60 + (24 * 60)) - (start_hour * 60)

    if start_min < end_min
      console.debug 'start_min < end_min', start_min, end_min
      mins = mins + (end_min - start_min)
    else
      console.debug 'start_min > end_min', start_min, end_min
      mins = mins + ((end_min + 60) - start_min) - 60

    if mins == 0
      "<span class='red'>0</span>"
    else if mins < 60
      "#{mins} minutes"
    else if mins == 60
      "1 hour"
    else if mins > (60 * 12) or mins == 0
      "<span class='red'>#{@hourize(mins)} hours</span>"
    else if mins > 60
      "#{@hourize(mins)} hours"

  valid_dates: ->
    from = @get('valid_from_at')
    unt  = @get('valid_until_at')

    if not from and not unt
      return '- -'

    if from.toLowerCase() == 'now' and unt.toLowerCase() == 'forever'
      return '- -'

    "#{from} - #{unt}"

  services: ->
    co = []
    model_services = @get('services') || []
    for service in model_services
      co.push Scp.Co.Services.findWhere
        id: parseInt(service)

    co

  hourize: (mins)->
    return mins if not mins

    s = (mins / 60) + ""
    c = s.split('.')

    if c.length > 1
      "#{c[0]}.#{c[1][0]}"
    else
      c[0]

class Scplanner.Collections.BreaksCollection extends Backbone.Collection
  model: Scplanner.Models.Break
  url: ->
    "/businesses/#{Scp.business_id}/break_shifts"

  add_batch: (data)->
    console.debug 'add_batch', data
    for day in data.days
      @add
        day: day
        services: data.services
        offices: data.offices
        valid_from_at:  data.valid_from_at
        valid_until_at: data.valid_until_at
        floating_break: data.floating_break
        start_hour: data.start_hour
        start_minute: data.start_minute
        start_meridian: data.start_meridian
        end_hour: data.end_hour
        end_minute:  data.end_minute
        end_meridian: data.end_meridian
