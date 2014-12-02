class OrderedView extends Backbone.View

  events:
    'click .down': 'down'
    'click .up': 'up'

  tagName: 'div'
  className: 'item'

  constructor: (opts)->
    super(opts)

    @$el.attr 'data-item-sort', @model.get('sort_order')
    @$el.data 'view', @

  up: ->
    @move parseInt(@model.get 'sort_order'), -1

  down: ->
    @move parseInt(@model.get 'sort_order'), +1

  move: (order, dir)->
    console.debug 'UserOrderView: move()', order, dir
    target_order = order + dir

    return false if target_order < 1

    target = @$el.parent().find(".item[data-item-sort='#{target_order}']").first()
    target_view = target.data('view')

    console.debug 'target:', target

    if dir < 0 # UP
      @$el.insertBefore(target)
    else # DOWN
      @$el.insertAfter(target)

    # Update the dom data markers
    target.attr 'data-item-sort', order
    @$el.attr 'data-item-sort', target_order
    @$el.attr 'data-item', @model.toJSON()

    @update(target_order)

    # Update the other view/model entity
    target_view.update(order)



  update: (order)=>
    @$('span.count').text(order)

    @model.set sort_order: order
    @model.save()





# Export namespace to global window
window.OrderedView = OrderedView
