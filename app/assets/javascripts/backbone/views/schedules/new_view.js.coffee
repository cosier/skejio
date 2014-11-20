Scplanner.Views.Schedules ||= {}

class Scplanner.Views.Schedules.NewView extends Backbone.View
  # template: JST["backbone/templates/schedules/new"]
  el: '#schedule-container'

  events:
    "submit form": "save"
    "click .btn-add-time-sheet": "click_add_time_sheet"
    "click .btn-save-everything": "save"
    "change #schedule_rule_service_provider_id": 'change_update_service_provider'

  time_sheets: new Scplanner.Collections.TimeSheetsCollection()
  services:    new Scplanner.Collections.ServicesCollection()

  last_cache: {}
  time_sheet_views: new Backbone.Collection()

  constructor: (options) ->
    super(options)

    self   = @
    preload_schedule = Scp.Preload and Scp.Preload.data.schedule_rule || {}
    @model = new Scplanner.Models.ScheduleRule(preload_schedule)

    window.NewView = @
    window.Scp.Co || = {}

    Scp.Co.Providers = new Scplanner.Collections.ProvidersCollection(Scp.Data.providers)
    Scp.Co.Services = new Scplanner.Collections.ServicesCollection(Scp.Data.services)
    Scp.Co.Offices  = new Scplanner.Collections.OfficesCollection(Scp.Data.offices)

    communicator = new Backbone.Model()

    # Watch for updates on entries — so we can update the tab count
    communicator.bind 'update_tab_count', ->
      self.render_tab_counts()

    @brk_man_view = new Scplanner.Views.Schedules.BreakManagerView
      model: communicator
      schedule_rule: @model

    if Scp.Preload
      Scp.Preload.time_sheets.each (time_sheet)=>
        @add_time_sheet(time_sheet)
    else
      @add_time_sheet(false)

    @render()
    @render_time_sheets()

  change_update_service_provider: (e)=>
    console.debug 'Updating Service Provider'
    id = $(e.target).val()
    @model.set(service_provider_id: id)
    @model.save() if @model.id

  click_add_time_sheet: (evt)=>
    btn = $(evt.target)
    btn.hide()
    $('body').animate({ 'scrollTop': $('body').height() })

    setTimeout =>

      @add_time_sheet()
      @render_time_sheets()
      setTimeout ->
        $('body').stop()
        $('body').animate({ 'scrollTop': $('body').height() })
      btn.delay(3000).fadeIn()
    , 200

  add_time_sheet: (model)=>
    model = new Scplanner.Models.TimeSheet() if not model or model.target

    model.bind 'destroy', =>
      @remove_timesheet(model)

    @time_sheets.add(model)

    @$('#schedule_rule_services').selectpicker('refresh')

    Scp.datetimepicker @$('.date')

  save: (e) =>
    console.debug 'Saving Everything'
    e.preventDefault()
    e.stopPropagation()
    self = @
    service_provider_id = @$("select#schedule_rule_service_provider_id").val()

    payload =
      service_provider_id: service_provider_id
      sheets: []
      breaks: []

    validation_fail = false

    if not service_provider_id or service_provider_id.length == 0
      validation_fail = true
      alert "You must select a *Available/Free* Service Provider."
      return false

    @$('.time-sheet.row').each (i, el)->
      sheet = $(el).data('view')
      sheet_payload = sheet.payload()

      validation_fail = true unless sheet_payload
      payload.sheets.push sheet_payload


    # bail early if we have validation inconsistencies
    payload.breaks = @$('.breaks').data('view').payload()

    if payload.breaks.length == 0 and not validation_fail
      if not confirm 'You havn\'t added any Breaks for this User yet, continue?'
        validation_fail = true


    return false if validation_fail

    @model.unset("errors")
    @model.set(payload)
    @model.save @model.toJSON(),
      success: (result)->
        console.debug 'ScheduleRule: saved', result
        window.location = self.model.url()
      error: (error)->
        alert 'Oops something strange happened, please refresh the page and try again'
        console.error 'ScheduleRule: save failed', error



  render_time_sheets: ->
    @current_time_sheets ||= {}

    @$('.time-sheet').each (i, el)=>
      @current_time_sheets[$(el).data('view').model.cid] = true

    @time_sheets.each (sheet)=>
      unless @current_time_sheets[sheet.cid]
        @render_time_sheet(sheet)

    add_btn = $('.btn-add-time-sheet')
    spinner = $('.time-sheet-spinner')
    spinner.addClass('hidden')

    if add_btn.hasClass 'hidden'
      add_btn.removeClass('hidden')

  render_time_sheet: (sheet)->
    console.debug "TimeSheetView:render_time_sheet()"
    container = @$('.top-time-sheet-entries')
    self = @

    # Watch for updates on entries — so we can update the tab count
    sheet.bind 'update_tab_count', ->
      self.render_tab_counts()

    view = new Scplanner.Views.Schedules.TimeSheetView
      schedule_rule: @model
      model: sheet

    @time_sheet_views.add({view: view})

    container.append(view.render().el)
    $('.bootstrap-select').selectpicker()

  remove_timesheet: (sheet)->
    console.debug "Removing Timesheet for #{sheet.get('name')}"
    @time_sheets.remove(sheet)

    container  = @$('.service-entries')
    time_sheet = @$(".time-sheet[service-id=#{sheet.cid}]")
    time_view  = time_sheet.data('view')

    time_view.remove() if time_view

  render_tab_counts: =>
    av_count = 0
    brk_count = 0

    @time_sheet_views.each (model)->
      view = model.get('view')
      av_count += view.get_time_entry_count()

    if @brk_man_view
      brk_count += @brk_man_view.get_time_entry_count()

    $('#availability-tab .count').html("(#{av_count})")
    $('#breaks-tab .count').html("(#{brk_count})")

  render: ->
    @$('.break-entries').html(@brk_man_view.render().el)

    # Show the save button for not preload scenarios (new form)
    @$('.btn-save-everything').removeClass('hidden') if not Scp.Preload

    return this
