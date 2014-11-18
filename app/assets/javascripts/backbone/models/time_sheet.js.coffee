class Scplanner.Models.TimeSheet extends Backbone.Model
  paramRoot: 'time_sheet'

  defaults: {}

  valid_until_label: ->
    unt = @get('valid_until_at')

    if unt and unt.toLowerCase() != 'forever'
     return moment(unt).format('MM/DD/YYYY')

    'Forever'

  valid_from_label: ->
    unt = @get('valid_from_at')

    if unt and unt.toLowerCase() != 'now'
     return moment(unt).format('MM/DD/YYYY')

    'Now'

class Scplanner.Collections.TimeSheetsCollection extends Backbone.Collection
  model: Scplanner.Models.TimeSheet
  url: ->
    "/businesses/#{Scp.business_id}/time_sheets"
