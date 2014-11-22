class ServiceSelectionView extends Backbone.View

  el: '#service_selection_content'
  events:
    'change input[type=radio]': 'changed'
  
  constructor: (opts)->
    super(opts)
    @update_state @$('input:checked').closest('.col')


  changed: (e)=>
    console.debug 'service_selection: input changed'
    @update_state(e.target)

  update_state: (target)->
    @$('select').attr('disabled', true)
    $(target).closest('.col').find('select').attr('disabled', false)


# Export namespace to global window
window.ServiceSelectionView = ServiceSelectionView
