class Scplanner.Models.TimeSheetService extends Backbone.Model
  paramRoot: 'time_sheet_service'

  defaults: {}

class Scplanner.Collections.TimeSheetServicesCollection extends Backbone.Collection
  model: Scplanner.Models.TimeSheetService
  url: ->
    "/businesses/#{Scp.business_id}/time_sheet_services"
