class Scplanner.Models.Provider extends Backbone.Model
  paramRoot: 'provider'

  defaults: {}

class Scplanner.Collections.ProvidersCollection extends Backbone.Collection
  model: Scplanner.Models.Provider
  url: '/api/providers'
