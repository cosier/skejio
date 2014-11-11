Scplanner.Views.Schedules ||= {}

class Scplanner.Views.Schedules.TimeSheetView extends Backbone.View
  template: JST["backbone/templates/schedules/time_sheet"]
  className: "time-sheet col-lg-12"
  events:
    "click .destroy": "destroy"

  entries: []

  constructor: (options) ->
    super(options)
    @services = Scp.Co.Services
    @offices  = Scp.Co.Offices

    @$el.attr('service-id', @model.id)
    @$el.data('view', @)


  destroy: =>
    console.debug "Destroying View", @
    @model.trigger('destroy')
    @remove()

  render: ->
    @$el.html @template
      model:    @model.toJSON()
      services: @services
      offices:  @offices

    $(this).data('view', @)

    return this
