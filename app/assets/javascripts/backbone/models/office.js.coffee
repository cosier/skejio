class Scplanner.Models.Office extends Backbone.Model
  paramRoot: 'office'

  defaults: {}

class Scplanner.Collections.OfficesCollection extends Backbone.Collection
  model: Scplanner.Models.Office
  url: '/api/offices'
