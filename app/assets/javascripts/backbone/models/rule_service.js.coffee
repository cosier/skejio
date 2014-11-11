class Scplanner.Models.RuleService extends Backbone.Model
  paramRoot: 'rule_service'

  defaults: {}

class Scplanner.Collections.RuleServicesCollection extends Backbone.Collection
  model: Scplanner.Models.RuleService
  url: '/api/rule_services'
