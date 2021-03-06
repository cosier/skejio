Scplanner.Views.Schedules ||= {}

class Scplanner.Views.Schedules.TimeSheetView extends Backbone.View
  template: JST["backbone/templates/schedules/time_sheet"]
  className: "time-sheet row"

  events:
    "click .destroy" :         "destroy"
    "focus input.date" :       "show_picker"
    "click .edit-time-sheet-service" : "edit_service"
    "click .btn-add-service" : "add_service"
    "click .btn-add-entry" :   "add_entry"
    "click .edit-validity" :   "edit_validity"
    "click .save-validity" :   "save_validity"

    "click .save-services" :   "save_services"
    "click .edit-services" :   "edit_services"

    "click .btn-open-creator" :   "open_creator"

  constructor: (options) ->
    super(options)
    @schedule_rule = options.schedule_rule
    @timesheet_services = new Scplanner.Collections.ServicesCollection()
    @entries = new Scplanner.Collections.TimeEntriesCollection()

    @services = Scp.Co.Services
    @offices  = Scp.Co.Offices

    if Scp.Preload
      models = Scp.Preload.time_entries.where(time_sheet_id: parseInt(@model.id))
      console.debug "TimeSheetView(#{@model.id}): Preloading Time Sheet with Data", models

      @entries.reset models
      @timesheet_services.reset Scp.Preload.time_sheet_services.where(time_sheet_id: parseInt(@model.id))

    @$el.attr('service-id', @model.id)
    @$el.data('view', @)

    @entries.bind 'destroy', (entry)=>
      @update_tab_count()

    @entries.bind 'remove', (entry)=>
      @update_tab_count()

    @entries.bind 'add', (entry)=>
      console.debug 'bind:add', entry
      @render_entry(entry)
      @update_tab_count()
      entry.save() if @schedule_rule.id

  open_creator: ->
    console.debug 'open_creator'
    @$('.creator').addClass('open')
    @$('.creator').removeClass('closed')

  close_creator: ->
    console.debug 'close_creator'
    @$('.creator').addClass('closed')
    @$('.creator').removeClass('open')

  update_tab_count: =>
    console.debug 'model.trigger:update_tab_count'
    @model.trigger 'update_tab_count'

  get_time_entry_count: =>
    parseInt @entries.length

  show_picker: (e)->
    el  = $(e.target)
    val = el.val().toLowerCase()

    if val.indexOf('forever') or val.indexOf('now')
      el.val('')

    console.debug 'show_picker', e

  edit_services: =>
    @$('.time-sheet-services').removeClass('closed')
    @$('.time-sheet-services').addClass('open')

  save_services: =>
    @$('.time-sheet-services').removeClass('open')
    @$('.time-sheet-services').addClass('closed')
    label_text = @$('.selection button.multiselect').text()
    console.debug 'label_text', label_text
    @$('.message .txt').html label_text
    @save()

  edit_validity: =>
    @$('.validity').removeClass('closed')
    @$('.validity').addClass('open')

  save_validity: =>
    @$('.validity').removeClass('open')
    @$('.validity').addClass('closed')
    @save()

  save: ->
    console.debug 'TimeSheetView:save()', @schedule_rule
    if @schedule_rule.id
      @model.set @payload()
      @model.save {},
        success: (entry)->
          console.debug('TimeSheetView:save Success', entry)
        error: (entry)->
          console.error('TimeSheetView:save Error', entry)
          console.error entry.errors


  destroy: =>
    console.debug "Destroying View", @
    @model.trigger 'update_tab_count'
    @model.trigger('destroy')
    @model.destroy()
    @remove()

  add_all_entries: =>
    console.debug "TimeSheetView: Adding All Entries", @entries
    @entries.each (entry)=>
      console.debug "TimeSheetView: Adding ->", entry
      @render_entry(entry)


  add_entry: ->
    console.debug "TimeSheetView:add_entry()"
    end_hour      = parseInt @$('select.end').val().split(':')[0]
    end_minute    = parseInt @$('select.end').val().split(':')[1]
    start_hour    = parseInt @$('select.start').val().split(':')[0]
    start_minute  = parseInt @$('select.start').val().split(':')[1]
    provider_id   = @schedule_rule.get('service_provider_id')
    service_id    = @schedule_rule.get('service_id')

    @entries.add_batch
      time_sheet_id: @model.id
      office_id: parseInt(@$('select.office').val())
      provider_id: provider_id
      service_id: service_id
      days:  @$('select.entry-days[multiple]').val()

      start_meridian: @$('select.start-meridian').val()
      end_meridian:   @$('select.end-meridian').val()

      start_hour:    start_hour
      start_minute:  start_minute
      end_hour:      end_hour
      end_minute:    end_minute
      save: true


    @process_entry_empty_state()
    console.debug 'add_entry', @entries
    @close_creator()

  process_entry_empty_state: ->
    if @entries.models.length > 0
      @$('tr.no-time-entries').addClass('hidden')
    else
      @$('tr.no-time-entries').removeClass('hidden')

  add_service: ->
    console.debug 'add_service'
    select = @$('select.services.bootstrap-select')
    id = select.val()

    # bail if we don't have a propper id
    return false unless id

    name = @$('select.services.bootstrap-select + .bootstrap-select span.filter-option').html()

    model = new Scplanner.Models.Service
      id: id
      name: name

    @timesheet_services.add(model)
    @render_services()

    select.find("option[value=#{id}]").remove()
    select.selectpicker('refresh')

  remove_service: (service)->
    console.debug 'Removing Service'
    @timesheet_services.remove(service)

    select = @$('select.services.bootstrap-select')
    select.append($("""<option value='#{service.id}'>#{service.get('name')}</option>"""))
    select.selectpicker('refresh')


  render_all_entries: =>
    #console.debug 'TimeSheetView:render_all_entries()'
    @entries.each (entry)=>
      @render_entry entry

  render_entry: (entry)->
    #console.debug "TimeSheetView:render_entry()"
    container = @$('table.entries tbody')

    entry.bind 'destroy', =>
      @entries.remove(entry)
      @process_entry_empty_state()

    view = new Scplanner.Views.Schedules.TimeEntryView
      model: entry

    container.append(view.render().el)


  render_services: ->
    self = @
    container = @$('td.service-list')
    container.empty()

    @timesheet_services.each (service)->
      service.bind 'destroy', ->
        self.remove_service(service)

      view = new Scplanner.Views.ServiceLabelView
        model: service

      container.append(view.render().el)

  payload: =>
    if @entries.length == 0
      alert 'Oops, you have a Time Sheet with no Entries.'
      return false

    data =
      id: @model.id

      valid_from_at: @$('.from input').val()
      valid_until_at: @$('.until input').val()

      services:
        @$('select.services-selection').val()

      entries:
        @entries.map (entry)->
          entry.toJSON()

  insert_option_intervals: ->
    start = @$('select.start')
    end   = @$('select.end')

    html = []
    selected = false

    for hour in [1...13] by 1
      selected = 'selected' if hour == 9 and not selected
      for min in [0...59] by 5
        if min < 10
          min = "0#{min}"

        html.push "<option value='#{hour}:#{min}' #{selected}>#{hour}:#{min}</option>"
        selected = false

    html = html.join('')

    # console.debug "HTML", html
    start.html(html)
    end.html(html)

  render: =>
    console.debug "TimeSheetView:render()", @model.toJSON()
    @$el.html @template
      model:    @model.toJSON()
      raw:      @model
      services: @services
      offices:  @offices

    @render_all_entries()
    @update_tab_count()
    @process_entry_empty_state()
    
    Scp.datetimepicker @$('input.time-sheet-valid-until')
    Scp.datetimepicker @$('input.time-sheet-valid-from') 
      
    @insert_option_intervals()
    @$('select[multiple]').each (i, select)->
      select = $(select)
      select.multiselect
        buttonWidth: select.attr('button-width') || 350
        includeSelectAllOption: true
        selectAllText: 'Select All'

        buttonText: (options, select) ->
          return (select.attr('label') || 'Select Work Days') if options.length == 0

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
          if select.attr('label-count')
            if parseInt(select.attr('total')) <= labels.length
              "All #{select.attr('label-count')}"
            else if labels.length == 1
              "#{labels[0]}"
            else
              "#{labels.length} #{select.attr('label-count')}"
          else
            labels.join(", ") + " "


    $(this).data('view', @)
    @$('*[data-toggle="tooltip"]').tooltip()
    return this
  #####################################
  # end @render



