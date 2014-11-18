class Scp.Services.PreloadService

  constructor: (data)->
    @data =  data
    @time_sheets = new Scplanner.Collections.TimeSheetsCollection
    @time_sheet_services = new Scplanner.Collections.TimeSheetServicesCollection
    @time_entries = new Scplanner.Collections.TimeEntriesCollection
    @break_shifts = new Scplanner.Collections.BreaksCollection
    @break_services = new Scplanner.Collections.BreakServicesCollection
    @break_offices = new Scplanner.Collections.BreakOfficesCollection

    @time_sheet_services.reset    data.time_sheet_services
    @time_sheets.reset    data.time_sheets
    @time_entries.reset   data.time_entries
    @break_shifts.reset   data.break_shifts
    @break_services.reset data.break_services
    @break_offices.reset  data.break_offices


  go: ->
    @break_shifts.map (brk)->
      brk.preload()
