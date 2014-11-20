Scplanner.Views.Schedules ||= {}

class Scplanner.Views.Schedules.BreakView extends Backbone.View
  template: JST["backbone/templates/schedules/break"]
  className: "break-entry"
  tagName: 'tr'

  events:
    "click .save":      "save"
    "click .edit":      "edit"
    "click .destroy":   "destroy"

  DAYS: ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday']

  constructor: (options) ->
    super(options)

    @services = Scp.Co.Services
    @offices  = Scp.Co.Offices
    @schedule_rule = options.schedule_rule

    @$el.data('view', @)
    @$el.attr('data-id', @model and @model.id)

  destroy: =>
    console.debug "Destroying TimeEntry", @
    @model.trigger('destroy')
    @model.destroy()
    @remove()

  save: ->
    console.debug 'break_view:save'
    @state = 'normal'
    end_hour       = parseInt @$('select.edit-end').val().split(':')[0]
    end_minute     = parseInt @$('select.edit-end').val().split(':')[1]
    start_hour     = parseInt @$('select.edit-start').val().split(':')[0]
    start_minute   = parseInt @$('select.edit-start').val().split(':')[1]
    start_meridian = @$('select.edit-start-meridian').val()
    end_meridian   = @$('select.edit-end-meridian').val()
    floating_break  = parseInt @$('.floating-editor').val()

    @model.set
      floating_break: floating_break
      schedule_rule_id: @schedule_rule and @schedule_rule.id
      day: @$('select.edit-day').val()
      start_meridian: start_meridian
      start_hour: start_hour
      start_minute: start_minute
      end_meridian: end_meridian
      end_hour: end_hour
      end_minute: end_minute

    @model.save {},
      success: (brk)->
        console.debug('BreakView:save --> Success', brk)
      error: (brk)->
        console.error('BreakView:save --> Error', brk)
        console.error brk.errors

    @render()

  edit: ->
    console.debug 'break_view:edit'
    @state = 'edit'
    @render()

    @insert_option_intervals('start')
    @insert_option_intervals('end')

  insert_option_intervals: (type)->
    select = @$("select.edit-#{type}")

    html = []
    selected = false

    model_hour = parseInt @model.get("#{type}_hour")
    model_min  = parseInt @model.get("#{type}_minute")
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
    select.html(html)

  render: =>
    @$el.html @template
      DAYS:     @DAYS
      state:    @state
      model:    @model
      services: @services
      offices:  @offices

    return this
