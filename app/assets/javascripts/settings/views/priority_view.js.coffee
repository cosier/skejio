class PriorityView extends Backbone.View


  constructor: (opts)->
    console.debug 'PriorityView:init'
    super(opts)

    @collection_klazz = opts.collection
    @model_klazz = opts.model
    @view_klazz = opts.view || OrderedView

    @build_data_model()
    @render()

  build_data_model: ->
    @collection = new @collection_klazz()

    # Extract user json from the initial dom
    @$('.item').each (i, el)=>
      view = new @view_klazz
        el: el
        model: new @model_klazz $(el).data('item')

      console.debug i, view.model
      @collection.add view.model


  render: ->
    console.debug "PriorityView:render()"




# Export namespace to global window
window.PriorityView = PriorityView
