class Scplanner.Models.ScheduleRule extends Backbone.Model
  paramRoot: 'schedule_rule'

  defaults: {}

class Scplanner.Collections.ScheduleRulesCollection extends Backbone.Collection
  model: Scplanner.Models.ScheduleRule
  url: '/api/schedule_rules'
