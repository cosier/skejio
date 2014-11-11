class Scplanner.Models.Service extends Backbone.Model
  paramRoot: 'service'

  defaults: {}

class Scplanner.Collections.ServicesCollection extends Backbone.Collection
  model: Scplanner.Models.Service
  url: '/api/services'
