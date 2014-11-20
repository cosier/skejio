class Scplanner.Models.BreakOffice extends Backbone.Model
  paramRoot: 'break_office'

  defaults: {}

class Scplanner.Collections.BreakOfficesCollection extends Backbone.Collection
  model: Scplanner.Models.BreakOffice
  url: ->
    "/businesses/#{Scp.business_id}/break_services"
