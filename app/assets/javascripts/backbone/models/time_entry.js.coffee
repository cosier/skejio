class Scplanner.Models.TimeEntry extends Backbone.Model
  paramRoot: 'time_entry'

  defaults: {}

  constructor: (options)->
    super(options)
    console.debug "TimeEntry: constructed", @

  office: ->
    Scp.Co.Offices.findWhere
      id: @get('office_id')

  pretty: (key)->
    v = parseInt(@get(key))
    if v < 10
      v = "0#{v}"

    v
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
