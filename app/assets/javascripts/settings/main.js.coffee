#= require_tree './views'

load_page = (page)->
  page = "office-selection" unless page

  console.debug "load_page: #{page}"
  $("a[data-hash='#{page}']").tab('show')
  $('.tab-content.hidden').removeClass('hidden')
  $('#settingTabs.hidden').removeClass('hidden')

$ ->

  console.debug 'Settings/main.js -> init'

  service_selection_view = new ServiceSelectionView()

  user_priority_view = new PriorityView
    el: '#providers-priority-container'
    collection: Scplanner.Collections.UsersCollection
    model: Scplanner.Models.User

  service_priority_view = new PriorityView
    el: '#services-priority-container'
    collection: Scplanner.Collections.ServicesCollection
    model: Scplanner.Models.Service

  Scplanner.Collections.OfficesCollection.url = "/api/businesses/#{Scp.business_id}/offices"

  office_priority_view = new PriorityView
    el: '#offices-priority-container'
    collection: Scplanner.Collections.OfficesCollection
    model: Scplanner.Models.Office

  #setTimeout ->
    #$('.container-fluid > .alert').fadeOut()
  #, 2000

  $(document).on 'shown.bs.tab', 'a', (evt)->
    console.debug 'Tab Changed', evt.target
    el = $(evt.target)
    window.location.hash = el.data('hash')


  hash = window.location.hash.replace /#/g, ''
  if hash.length < 1
    hash = 'office-selection'
    window.location.hash = hash

  load_page hash

