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

  services: ->
    co = new Scplanner.Collections.ServicesCollection()
    
    model_services = []
    ui_services = @get('services') || []

    if Scp.Preload
      model_services = Scp.Preload.time_sheet_services.where(time_sheet_id: @id)


    add = (service)->
      if service
        co.add service 
        console.debug "Service found: #{id}"
      else
        console.debug "Service not found: #{id}", @get('services'), break_service

    for model in model_services
      service = Scp.Co.Services.findWhere id: parseInt(model.id)
      add(service)

    for id in ui_services 
      service = Scp.Co.Services.findWhere id: parseInt(id)
      add(service)

    co.models

class Scplanner.Collections.TimeSheetsCollection extends Backbone.Collection
  model: Scplanner.Models.TimeSheet
  url: ->
    "/businesses/#{Scp.business_id}/time_sheets"
