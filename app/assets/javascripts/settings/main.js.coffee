
load_page = (page)->
  page = "service-selection" unless page

  console.debug "load_page: #{page}"
  $("a[data-hash='#{page}']").tab('show')
  $('.tab-content.hidden').removeClass('hidden')
  $('#settingTabs.hidden').removeClass('hidden')

$ ->
  console.debug 'Settings/main.js -> init'
  setTimeout ->
    $('.alert').fadeOut()
  , 2000

  $('.service-selections input[type=radio]').change (evt)->
    console.debug 'Changed!'

  $(document).on 'shown.bs.tab', 'a', (evt)->
    console.debug 'Tab Changed', evt.target
    el = $(evt.target)
    window.location.hash = el.data('hash')


  hash = window.location.hash.replace /#/g, ''
  if hash.length < 1
    hash = 'service-selection'
    window.location.hash = hash

  load_page hash

