class UserSelectionView extends Backbone.View

  el: '#user_selection_content'

  events:
    'change input[type=radio]': 'changed'

  constructor: (opts)->
    super(opts)
    setTimeout @changed, 200

  changed: ()=>
    el = @$('input[name="setting[user_selection_type]"]:checked')
    val = el.val()
    target = el.closest('.col').next().find('.options-container')

    console.debug "user_selection: input changed(#{val})"
    @$('.service-provider-options').appendTo(target)



# Export namespace to global window
window.UserSelectionView = UserSelectionView
