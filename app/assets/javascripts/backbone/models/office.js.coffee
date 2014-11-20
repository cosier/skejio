class Scplanner.Models.Office extends Backbone.Model
  paramRoot: 'office'

  defaults: {}

class Scplanner.Collections.OfficesCollection extends Backbone.Collection
  model: Scplanner.Models.Office
  url: ->
    "/businesses/#{Scp.business_id}/offices"
