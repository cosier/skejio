class Scplanner.Models.BreakService extends Backbone.Model
  paramRoot: 'break_service'

  defaults: {}

class Scplanner.Collections.BreakServicesCollection extends Backbone.Collection
  model: Scplanner.Models.BreakService
  url: ->
    "/businesses/#{Scp.business_id}/break_services"
