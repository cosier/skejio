class UserPriorityView extends Backbone.View

  el: '#user_priority_content'
  events:
    'change input[type=radio]': 'changed'

  constructor: (opts)->
    console.debug 'UserPriorityView:init'
    super(opts)
    @container = @$("#user-priority-container")
    @process_visibility()
    @render()

  changed: (e)=>
    console.debug 'service_selection: input changed'
    @process_visibility()

  process_visibility: ->
    if @$('input:checked').val() == "custom"
      console.debug "UserPriorityView: custom detected"
      @container.removeClass 'hidden'
    else
      @container.addClass 'hidden'


  render: ->
    console.debug "UserPriorityView:render()"




# Export namespace to global window
window.UserPriorityView = UserPriorityView
