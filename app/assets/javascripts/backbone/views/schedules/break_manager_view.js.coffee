Scplanner.Views.Schedules ||= {}

class Scplanner.Views.Schedules.BreakManagerView extends Backbone.View
  template: JST["backbone/templates/schedules/break_manager"]
  className: "breaks row"

  events:
    "click .btn-add-break": "create_break"
    "click .destroy":       "destroy"
    "click .configure-office .open":  "enable_office_specification"
    "click .configure-office .close":  "disable_office_specification"
    "click .configure-service-specification .open":  "enable_service_specification"
    "click .configure-service-specification .close":  "disable_service_specification"
    "click .configure-rule-expiration .open":  "enable_rule_expiration"
    "click .configure-rule-expiration .close":  "disable_rule_expiration"
    "focus .valid_dates input":  "picker_activated"
    "change .valid_dates input":  "picker_changed"

  breaks: new Scplanner.Collections.BreaksCollection()

  view_vars:
    enable_date_validity: false
    enable_service_specification: false

  constructor: (options) ->
    super(options)
    self = @

    @services = Scp.Co.Services
    @offices  = Scp.Co.Offices

    @schedule_rule = options.schedule_rule

    @$el.data('view', @)

    @breaks.bind 'destroy', (brk)=>
      self.model.trigger 'update_tab_count'

    @breaks.bind 'remove', (brk)=>
      self.model.trigger 'update_tab_count'

    @breaks.bind 'add', (brk)=>
      self.model.trigger 'update_tab_count'

      $('tr.pregame').addClass 'hidden'
      self.add_break(brk)

      if @schedule_rule.id and not brk.id
        brk.save {},
          success: (brk)->
            console.debug 'Break: saved successfully'
          error: (brk)->
            console.error 'Break: was not saved', brk
            console.error """
            Oops, something happened trying to save the Break entry.
            Please refresh the page and try again— or contact support"""

    if Scp.Preload
      Scp.Preload.break_shifts.each (entry)=>
        @breaks.add(entry)

    setInterval ->
      $('#valid_until').datetimepicker({pickTime: false})
      $('#valid_from').datetimepicker({pickTime: false})
    , 1000

  picker_changed: (e)->
    el  = $(e.target)
    val = el.val().toLowerCase()
    if val == ''
      el.val el.attr('data-empty-value') || 'forever'

  picker_activated: (e)->
    el  = $(e.target)
    val = el.val().toLowerCase()

    if val.indexOf('forever') >= 0 or val.indexOf('now') >= 0
      el.val('')

    console.debug 'show_picker', e

  get_time_entry_count: =>
    parseInt @breaks.length

  enable_rule_expiration: =>
    console.debug 'enable_rule_expiration'
    $('.date').datetimepicker pickTime: false
    @$('.configure-rule-expiration.state-view').removeClass('closed')
    @$('.configure-rule-expiration.state-view').addClass('open')
    @hooks()

  disable_rule_expiration: =>
    console.debug 'disable_rule_expiration'
    @$('.configure-rule-expiration.state-view').removeClass('open')
    @$('.configure-rule-expiration.state-view').addClass('closed')

  enable_service_specification: =>
    $('.date').datetimepicker pickTime: false
    console.debug 'enable_service_specification'
    @$('.configure-service-specification.state-view').removeClass('closed')
    @$('.configure-service-specification.state-view').addClass('open')
    @hooks()

  disable_service_specification: =>
    console.debug 'disable_service_specification'
    @$('.configure-service-specification.state-view').removeClass('open')
    @$('.configure-service-specification.state-view').addClass('closed')

  enable_office_specification: =>
    console.debug 'enable_office_specification'
    @$('.configure-office.state-view').removeClass('closed')
    @$('.configure-office.state-view').addClass('open')

  disable_office_specification: =>
    console.debug 'disable_office_specification'
    @$('.configure-office.state-view').removeClass('open')
    @$('.configure-office.state-view').addClass('closed')



  remove_break: (brk)->
    @breaks.remove(brk)

  add_break: (brk)->
    console.debug 'add_break', brk
    container = @$('table tbody')
    view = new Scplanner.Views.Schedules.BreakView
      model: brk
      schedule_rule: @schedule_rule

    brk.bind 'destroy', =>
      @remove_break(brk)

    container.append(view.render().el)

  create_break: ->
    console.debug "add_break"
    end_hour      = parseInt @$('select.end').val().split(':')[0]
    end_minute    = parseInt @$('select.end').val().split(':')[1]
    start_hour    = parseInt @$('select.start').val().split(':')[0]
    start_minute  = parseInt @$('select.start').val().split(':')[1]

    @breaks.add_batch
      schedule_rule_id: @schedule_rule and @schedule_rule.id
      days: @$('select.entry-days[multiple]').val()
      services: @$('select.choose-break-service').val() || []
      offices: @$('select.choose-break-office').val() || []
      start_meridian: @$('select.start-meridian').val()
      end_meridian:   @$('select.end-meridian').val()
      valid_from_at:     @$('input#valid_from').val()
      valid_until_at:    @$('input#valid_until').val()
      floating_break: @$('input.float').val()
      start_hour:    start_hour
      start_minute:  start_minute
      end_hour:      end_hour
      end_minute:    end_minute

  add_break_entries: =>
    container = @$('table.breaks-manager tbody')
    container.empty() if @breaks.length > 0

    self = @

    @breaks.each (brk)->

      brk.bind 'destroy', ->
        self.breaks.remove(brk)

      view = new Scplanner.Views.Schedules.BreakView
        schedule_rule: @schedule_rule
        model: brk

      container.append(view.render().el)

  insert_option_intervals: (type, marker)->
    select = @$("select.#{type}")


    html = []
    selected = false

    for hour in [1...13] by 1
      selected = 'selected' if hour == marker and not selected
      for min in [0...59] by 5
        if min < 10
          min = "0#{min}"

        html.push "<option value='#{hour}:#{min}' #{selected}>#{hour}:#{min}</option>"
        selected = false

    html = html.join('')

    # console.debug "HTML", html
    select.html(html)

  payload: ->
    @breaks.map (brk)->
      brk.toJSON()


  render: =>
    @$el.html @template
      services: @services
      offices:  @offices
      enable_date_validity: @view_vars.enable_date_validity
      enable_service_specification: @view_vars.enable_service_specification

    $('.date').datetimepicker
      pickTime: false

    @add_break_entries()
    @insert_option_intervals('start', 11)
    @insert_option_intervals('end', 12)
    @hooks()

    return this

  hooks: ->
    setTimeout =>

      $('.date').datetimepicker
        pickTime: false

      @$('.numeric').numeric()

      @$('select[multiple]').each (i, select)->
        # console.log 'select[multiple]', select
        select = $(select)
        select_all_option = true
        if select.attr('data-select-all') == 'false'
          select_all_option = false

        select.multiselect
          buttonWidth: 350
          includeSelectAllOption: select_all_option
          selectAllText: 'Select All'
          buttonText: (options, select) ->
            return select.attr('data-empty') || 'Select Work Days' if options.length == 0

            days = []
            options.map ->
              days.push($(this).attr 'value')

            if (days.length == 5 and days.indexOf('monday') >= 0 and days.indexOf('tuesday') >= 0 and days.indexOf('wednesday') >= 0 and days.indexOf('thursday') >= 0 and days.indexOf('friday') >= 0)
              return 'Monday to Friday'

            if (days.length == 6 and days.indexOf('monday') >= 0 and days.indexOf('tuesday') >= 0 and days.indexOf('wednesday') >= 0 and days.indexOf('thursday') >= 0 and days.indexOf('friday') >= 0 and days.indexOf('saturday') >= 0)
              return 'Monday to Saturday'

            if (days.length == 7)
              return 'Every Day'

            labels = []
            options.each ->
              if $(this).attr("lbl") isnt `undefined`
                labels.push "#{$(this).attr('lbl')}"
              else
                labels.push $(this).html()
              return

            labels.join(", ") + " "


