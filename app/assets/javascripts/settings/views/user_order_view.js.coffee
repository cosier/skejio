class UserOrderView extends Backbone.View

  events:
    'click .down': 'down'
    'click .up': 'up'

  tagName: 'div'
  className: 'user'

  constructor: (opts)->
    super(opts)

    @$el.attr 'data-user-sort', @model.get('sort_order')
    @$el.data 'view', @

  up: ->
    @move parseInt(@model.get 'sort_order'), -1

  down: ->
    @move parseInt(@model.get 'sort_order'), +1

  move: (order, dir)->
    console.debug 'UserOrderView: move()', order, dir
    target_order = order + dir

    return false if target_order < 1
    
    target = $(".user[data-user-sort='#{target_order}']")
    target_view = target.data('view')

    console.debug 'target:', target
    
    if dir < 0 # UP
      @$el.insertBefore(target)
    else # DOWN
      @$el.insertAfter(target)

    # Update the dom data markers
    target.attr 'data-user-sort', order
    @$el.attr 'data-user-sort', target_order
    @$el.attr 'data-user', @model.toJSON()

    @update(target_order)

    # Update the other view/model entity
    target_view.update(order)



  update: (order)=>
    @$('span.count').text(order)

    @model.set sort_order: order
    @model.save()


  


# Export namespace to global window
window.UserOrderView = UserOrderView
