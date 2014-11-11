Scplanner.Views.Schedules ||= {}

class Scplanner.Views.Schedules.NewView extends Backbone.View
  # template: JST["backbone/templates/schedules/new"]
  el: '#schedule-container'

  events:
    "submit form": "save"
    "click .btn-add-service": "add_service"

  services: new Scplanner.Collections.ServicesCollection()
  rules:    new Scplanner.Collections.RuleServicesCollection()

  last_cache: {}


  constructor: (options) ->
    super(options)

    window.Scp ||= {}
    window.Scp.Co || = {}

    Scp.Co.Services = new Scplanner.Collections.ServicesCollection(Scp.Data.services)
    Scp.Co.Offices  = new Scplanner.Collections.OfficesCollection(Scp.Data.offices)

    # @model = new @collection.model()

  remove_service: (service)->
    console.debug "Removing Service", service
    @services.remove(service)
    @remove_timesheet(service)

    select = @$('#schedule_rule_services')
    select.append($("<option value='#{service.id}'>#{service.get('name')}</option>"))
    select.selectpicker('refresh');

  add_service: =>
    id = @$('#schedule_rule_services').val() || @$('#schedule_rule_services option').first().attr('value')
    return false unless id
    # Get the select option element, and fallback to the first available one.
    # name = @$('#schedule_rule_services + .bootstrap-select > button span.filter-option').text()
    name = ''
    removed = false
    @$('#schedule_rule_services option').map ->
      el = $(@)
      if parseInt(el.val()) == parseInt(id)
        name = el.html()
        el.remove()
        removed = true

    model = new Scplanner.Models.Service
      id: id
      name: name

    model.bind 'destroy', =>
      @remove_service(model)

    @services.add model

    @render_services()
    @render_timesheets()
    @$('#schedule_rule_services').selectpicker('refresh')


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

  render_services: ->
    @container = $(".right .service-list")
    @container.empty()

    @services.each (service)=>
      console.debug "Adding Service:", service
      view = new Scplanner.Views.Services.ServiceLabelView
        model: service
      @container.append view.render().el

  render_timesheets: ->
    current_timesheets = {}

    @$('.time-sheet').each (i, el)->
      current_timesheets[$(el).data('view').model.id] = true

    @services.each (service)=>
      unless current_timesheets[service.id]
        @add_timesheet(service)

  add_timesheet: (service)->
    console.debug "Adding Timesheet"
    container = @$('.service-entries')

    view = new Scplanner.Views.Schedules.TimeSheetView
      model: service

    container.append(view.render().el)
    $('.bootstrap-select').selectpicker()

  remove_timesheet: (service)->
    console.debug "Removing Timesheet for #{service.get('name')}"
    container  = @$('.service-entries')
    time_sheet = @$(".time-sheet[service-id=#{service.id}]")
    time_view  = time_sheet.data('view')

    time_view.remove() if time_view

  render: ->
    @$el.html @template @model.toJSON()

    this.$("form").backboneLink(@model)

    return this