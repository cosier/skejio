class Scplanner.Models.TimeSheet extends Backbone.Model
  paramRoot: 'time_sheet'

  defaults: {}

class Scplanner.Collections.TimeSheetsCollection extends Backbone.Collection
  model: Scplanner.Models.TimeSheet
  url: '/api/time_sheets'
