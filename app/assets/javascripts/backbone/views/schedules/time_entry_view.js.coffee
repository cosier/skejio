Scplanner.Views.Schedules ||= {}

class Scplanner.Views.Schedules.TimeEntryView extends Backbone.View
  template: JST["backbone/templates/schedules/time_entry"]

  className: "time-entry"
  tagName: 'tr'

  events:
    "click .save": "save"
    "click .edit": "edit"
    "click .destroy": "destroy"
    "click .btn-add-service": "add_service"
    "click .btn-add-entry": "add_entry"


  DAYS: ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday']

  entries: new Scplanner.Collections.TimeEntriesCollection()
  timesheet_services: new Scplanner.Collections.ServicesCollection()

  constructor: (options) ->
    super(options)
    @offices = Scp.Co.Offices
    console.debug "TimeEntryView: constructor()", options

  save: =>
    @state = 'normal'
    end_hour       = parseInt @$('select.edit-end').val().split(':')[0]
    end_minute     = parseInt @$('select.edit-end').val().split(':')[1]
    start_hour     = parseInt @$('select.edit-start').val().split(':')[0]
    start_minute   = parseInt @$('select.edit-start').val().split(':')[1]
    start_meridian = @$('select.edit-start-meridian').val()
    end_meridian   = @$('select.edit-end-meridian').val()

    @model.set
      day: @$('select.edit-day').val()
      office_id: parseInt(@$('select.edit-office').val())
      start_meridian: start_meridian
      start_hour: start_hour
      start_minute: start_minute
      end_meridian: end_meridian
      end_hour: end_hour
      end_minute: end_minute

    @model.save() if @model.id

    console.debug "Saving TimeEntry", @
    @render()

  edit: =>
    @state = 'edit'
    console.debug "Editing TimeEntry", @
    @model.trigger('editing-engaged')
    @render()

    @insert_option_intervals('start')
    @insert_option_intervals('end')

  insert_option_intervals: (type)->
    select = @$("select.edit-#{type}")

    html = []
    selected = false

    model_hour = parseInt @model.get("#{type}_hour")
    model_min  = parseInt @model.get("#{type}_min")
    console.debug 'model_hour', model_hour
    console.debug 'model_min', model_min

    for hour in [1...13] by 1
      for min in [0...59] by 5
        if min < 10
          min = "0#{min}"

        selected = 'selected' if parseInt(hour) == model_hour and parseInt(min) == model_min

        html.push "<option value='#{hour}:#{min}' #{selected}>#{hour}:#{min}</option>"
        selected = false

    html = html.join('')

    # console.debug "HTML", html
    select.html(html)

  destroy: =>
    console.debug "Destroying TimeEntry", @
    @model.trigger('destroy')
    @model.destroy()
    @remove()

  render: ->
    @$el.html @template
      DAYS: @DAYS
      state: @state
      model:    @model
      offices:  @offices

    $(this).data('view', @)

    return this
