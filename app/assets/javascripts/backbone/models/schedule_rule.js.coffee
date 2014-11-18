class Scplanner.Models.ScheduleRule extends Backbone.Model
  paramRoot: 'schedule_rule'

  defaults: {}
  url: ->
    u = "/businesses/#{Scp.business_id}/schedule_rules"
    u = "#{u}/#{@id}" if @id
    u

class Scplanner.Collections.ScheduleRulesCollection extends Backbone.Collection
  model: Scplanner.Models.ScheduleRule
  url: ->
    "/businesses/#{Scp.business_id}/schedule_rules"
