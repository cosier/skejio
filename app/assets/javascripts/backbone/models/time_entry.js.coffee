class Scplanner.Models.TimeEntry extends Backbone.Model
  paramRoot: 'time_entry'

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


    console.debug "TimeEntry: constructed", @

  office: ->
    Scp.Co.Offices.findWhere
      id: @get('office_id')

  pretty: (key)->
    v = parseInt(@get(key))
    if v < 10
      v = "0#{v}"

    v

  hour: (type)->
    parseInt @get("#{type}_hour")

  minute: (type)->
    parseInt @get("#{type}_minute")

class Scplanner.Collections.TimeEntriesCollection extends Backbone.Collection
  model: Scplanner.Models.TimeEntry
  url: '/api/time_entries'

  add_batch: (data)->
    console.debug 'add_batch', data
    for day in data.days
      @add
        day: day
        start_hour: data.start_hour
        start_minute: data.start_minute
        start_meridian: data.start_meridian
        end_hour: data.end_hour
        end_minute:  data.end_minute
        end_meridian: data.end_meridian
        office_id: data.office_id
