Scplanner.Views.Schedules ||= {}

class Scplanner.Views.Schedules.NewView extends Backbone.View
  # template: JST["backbone/templates/schedules/new"]
  el: '#schedule-container'

  events:
    "submit form": "save"
    "click .btn-add-time-sheet": "add_time_sheet"

  time_sheets: new Scplanner.Collections.TimeSheetsCollection()
  services:    new Scplanner.Collections.ServicesCollection()

  last_cache: {}


  constructor: (options) ->
    super(options)

    window.Scp ||= {}
    window.Scp.Co || = {}

    Scp.Co.Providers = new Scplanner.Collections.ServicesCollection(Scp.Data.providers)
    Scp.Co.Services = new Scplanner.Collections.ServicesCollection(Scp.Data.services)
    Scp.Co.Offices  = new Scplanner.Collections.OfficesCollection(Scp.Data.offices)

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


  save: (e) ->
    e.preventDefault()
    e.stopPropagation()

    @model.unset("errors")
    return false

    @collection.create @model.toJSON(),
      success: (schedule_creator) =>
        @model = schedule_creator
        window.location.hash = "/#{@model.id}"

      error: (schedule_creator, jqXHR) =>
        @model.set({errors: $.parseJSON(jqXHR.responseText)})


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

    view = new Scplanner.Views.Schedules.TimeSheetView
      model: sheet

    container.append(view.render().el)
    $('.bootstrap-select').selectpicker()

  remove_timesheet: (sheet)->
    console.debug "Removing Timesheet for #{sheet.get('name')}"
    @time_sheets.remove(sheet)
    container  = @$('.service-entries')
    time_sheet = @$(".time-sheet[service-id=#{sheet.cid}]")
    time_view  = time_sheet.data('view')

    time_view.remove() if time_view

  render: ->

    brkManagerView = new Scplanner.Views.Schedules.BreakManagerView()
    $('.break-entries').html(brkManagerView.render().el)

    # this.$("form").backboneLink(@model)




    return this