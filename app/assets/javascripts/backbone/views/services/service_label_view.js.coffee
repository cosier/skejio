Scplanner.Views.Services ||= {}

class Scplanner.Views.Services.ServiceLabelView extends Backbone.View
  template: JST["backbone/templates/services/service_label"]
  className: "service-label"

  events:
    "click .destroy": "destroy"

  constructor: (options) ->
    super(options)
    # @model = new @collection.model()

  destroy: =>
    console.debug "Destroying View", @
    @model.trigger('destroy')
    @remove()

  render: ->
    @$el.html @template @model.toJSON()
    $(this).data('view', @)

    return this
