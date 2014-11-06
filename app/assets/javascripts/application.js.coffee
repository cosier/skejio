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
#= require jquery
#= require jquery_ujs
#= require vendor/jquery.rumble
#= require twitter/bootstrap
#= require_tree .
#= require_self

ready = ()->
  console.debug 'app:ready()'

  $("#menu-toggle").unbind('click').click (e) ->
    e.preventDefault()
    $("#wrapper").toggleClass "toggled"
    console.debug 'menu-toggle click'

$ ->

  $(".get-phonenumbers").bind "ajax:beforeSend", ->
    $("#loading").css "display", "block"
    return

  $(document).on "ready", ->
    ready()

  $(document).on "page:load", ->
    ready()