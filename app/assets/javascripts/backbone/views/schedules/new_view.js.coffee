Scplanner.Views.Schedules ||= {}

class Scplanner.Views.Schedules.NewView extends Backbone.View
  # template: JST["backbone/templates/schedules/new"]
  el: '#schedule-container'

  events:
    "submit form": "save"
    "click .btn-add-service": "add_service"

  services: []
  rules: []

  constructor: (options) ->
    super(options)
    # @model = new @collection.model()


  add_service: ->
    id = @$('#schedule_rule_services').val() || @$('#schedule_rule_services option').first().attr('value')

    # Get the select option element, and fallback to the first available one.
    name = @$('#schedule_rule_services + .bootstrap-select > button span.filter-option').text()

    console.debug "Adding Service:", id, name

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


  render: ->
    @$el.html @template @model.toJSON()

    this.$("form").backboneLink(@model)

    return this
