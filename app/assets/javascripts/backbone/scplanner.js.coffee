#= require_self
#= require_tree ./templates
#= require_tree ./models
#= require_tree ./views
#= require_tree ./routers
#= require_tree ./services

window.Scplanner =
  Models: {}
  Collections: {}
  Routers: {}
  Views: {}
  Services: {}


window.Scp ||= {}

Scp.datetimepicker = (element, opts)->
  element.datetimepicker
    timepicker: false
    format: 'm/d/Y'
    scrollInput: false
    scrollTime: false
    scrollMonth: false
