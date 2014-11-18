class TimeSheetsController < BusinessesController


  load_and_authorize_resource :business
  load_and_authorize_resource :time_sheet, parent: false

  layout 'business_console'
  sidebar  :schedules

  respond_to :json, :js, :xml, :html

  include EntryHelper

  def update
    d = time_sheet_params

    d[:valid_from_at]  = Chronic.parse d[:valid_from_at]
    d[:valid_until_at] = Chronic.parse d[:valid_until_at]

    d[:services].map { |id| Service.find(id) }.map { |service|
      if not @time_sheet.services.where(id: service.id).first
        @time_sheet.time_sheet_services.create!(
          service_id: service.id,
          business_id: @business.id)
      end
    }if d[:services]

    @time_sheet.update(d.except(:services, :entries, :time_sheet_services))
    respond_with(@time_sheet, location: business_time_sheet_path(@business, @time_sheet))
  end

  def destroy
    @time_sheet.destroy
    respond_with(@office, location: business_time_sheets_path(@business))
  end

  def create
  end

  private

  def time_sheet_params
    p = params.require(:time_sheet).permit!
    p[:business_id] = params[:business_id]
    p = convert_meridians(p)
    p.dup
  end
end
