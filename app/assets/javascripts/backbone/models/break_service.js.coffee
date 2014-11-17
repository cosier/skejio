class Scplanner.Models.BreakService extends Backbone.Model
  paramRoot: 'break_service'

  defaults: {}

class Scplanner.Collections.BreakServicesCollection extends Backbone.Collection
  model: Scplanner.Models.BreakService
  url: '/api/break_services'
