class Scplanner.Models.Break extends Backbone.Model
  paramRoot: 'break'

  defaults: {}

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

  offices: ->
    'All Offices'

  duration: ->
    mins = 0
    start_hour = parseInt @get('start_hour')
    start_min  = parseInt @get('start_min')
    end_hour   = parseInt @get('end_hour')
    end_min    = parseInt @get('end_min')

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

    if mins < 60
      "#{mins} minutes"
    else if mins == 60
      "1 hour"
    else if mins > (60 * 12)
      "<span class='red'>#{@hourize(mins)} hours</span>"
    else if mins > 60
      "#{@hourize(mins)} hours"

  valid_dates: ->
    from = @get('valid_from')
    unt  = @get('valid_until')

    if from.toLowerCase() == 'now' and unt.toLowerCase() == 'forever'
      return '- -'

    "#{from} - #{unt}"

  services: ->
    co = []
    for service in @get('services')
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
  url: '/api/breaks'

  add_batch: (data)->
    console.debug 'add_batch', data
    for day in data.days
      @add
        day: day
        services: data.services
        valid_from:  data.valid_from
        valid_until: data.valid_until
        floating_break: data.floating_break
        start_hour: data.start_hour
        start_min: data.start_min
        start_meridian: data.start_meridian
        end_hour: data.end_hour
        end_min:  data.end_min
        end_meridian: data.end_meridian