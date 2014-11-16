Scplanner.Views.Schedules ||= {}

class Scplanner.Views.Schedules.NewView extends Backbone.View
  # template: JST["backbone/templates/schedules/new"]
  el: '#schedule-container'

  events:
    "submit form": "save"
    "click .btn-add-time-sheet": "add_time_sheet"
    "click .btn-save-everything": "save"

  time_sheets: new Scplanner.Collections.TimeSheetsCollection()
  services:    new Scplanner.Collections.ServicesCollection()

  last_cache: {}
  time_sheet_views: new Backbone.Collection()

  constructor: (options) ->
    super(options)

    self   = @
    @model = new Scplanner.Models.ScheduleRule()

    window.Scp ||= {}
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

    @add_time_sheet()
    @render()

  add_time_sheet: =>
    model = new Scplanner.Models.TimeSheet

    model.bind 'destroy', =>
      @remove_timesheet(model)

    @time_sheets.add(model)

    @render_timesheets()

    @$('#schedule_rule_services').selectpicker('refresh')
    @$('.date').datetimepicker
      pickTime: false


  save: (e) =>
    console.debug 'Saving Everything'
    e.preventDefault()
    e.stopPropagation()

    payload =
      service_provider_id: @$('select#schedule_rule_service_provider_id').val()
      sheets: []
      breaks: []

    @$('.time-sheet.row').each (i, el)->
      sheet = $(el).data('view')
      payload.sheets.push sheet.payload()

    payload.breaks = @$('.breaks').data('view').payload()

    @model.unset("errors")
    @model.set(payload)

    @model.save
      success: (result)->
        console.debug 'ScheduleRule: saved', result
      error: (error)->
        console.error 'ScheduleRule: save failed', error



  render_timesheets: ->
    current_timesheets = {}

    @$('.time-sheet').each (i, el)->
      current_timesheets[$(el).data('view').model.cid] = true

    @time_sheets.each (sheet)=>
      unless current_timesheets[sheet.cid]
        @add_timesheet(sheet)

    add_btn = $('.btn-add-time-sheet')
    spinner = $('.time-sheet-spinner')
    spinner.addClass('hidden')

    if add_btn.hasClass 'hidden'
      add_btn.removeClass('hidden')

  add_timesheet: (sheet)->
    console.debug "Adding Timesheet"
    container = @$('.service-entries')
    self = @

    # Watch for updates on entries — so we can update the tab count
    sheet.bind 'update_tab_count', ->
      self.render_tab_counts()

    view = new Scplanner.Views.Schedules.TimeSheetView
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

    brk_count += @brk_man_view.get_time_entry_count()

    $('#availability-tab .count').html("(#{av_count})")
    $('#breaks-tab .count').html("(#{brk_count})")

  render: ->
    $('.break-entries').html(@brk_man_view.render().el)
    return this
