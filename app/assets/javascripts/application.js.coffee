# This is a manifest file that'll be compiled into application.js, which will include all the files
# listed below.
#
# Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
# or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
#
# It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
# compiled file.
#
# Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
# about supported directives.
#
#
#= require jquery
#= require jquery_ujs
#= require jquery.timeago
#= require jquery.numeric
#= require jquery.cookie
#= require jquery.sortable
#= require jquery.fileupload
#= require vendor/jquery.rumble
#= require twitter/bootstrap
#
#= require underscore
#= require backbone
#= require backbone_rails_sync
#= require backbone_datalink

#= require moment
#= require bootstrap-datetimepicker
#= require bootstrap_select/bootstrap-select
#= require bootstrap-multiselect
#= require select2
#
#= require_self
#
#= require underscore
#= require underscore.string
#= require backbone
#= require backbone_rails_sync
#= require backbone_datalink
#= require backbone/scplanner
#= require_tree .
#

# Prestate our namespace
window['Scp'] ||=
  Models: {}
  Collections: {}
  Routers: {}
  Views: {}
  Services: {}

# Function queue for iterative page loading
window['ready'] ||= []

ready_func = ()->
  console.debug 'app:ready()', ready
  $("#menu-toggle").unbind('click').click (e) ->
    e.preventDefault()
    $("#wrapper").toggleClass "toggled"
    console.debug 'menu-toggle click'

  $('.bootstrap-select').selectpicker
      style: 'btn-default',
      size: 4

  for func in ready
    func()

$ ->

  $(document).on "ready", ->
    ready_func()

  $(document).on "page:load", ->
    ready_func()