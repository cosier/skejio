class Scplanner.Models.Service extends Backbone.Model
  paramRoot: 'service'

  defaults: {}

class Scplanner.Collections.ScheduleRulesCollection extends Backbone.Collection
  model: Scplanner.Models.Service
  url: '/api/services'
