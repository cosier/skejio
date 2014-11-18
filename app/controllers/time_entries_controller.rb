class TimeEntriesController < BusinessesController


  load_and_authorize_resource :business
  load_and_authorize_resource :time_entry, parent: false

  layout 'business_console'
  sidebar  :schedules

  respond_to :json
  include EntryHelper

  def update
    @time_entry.update(time_entry_params)
    respond_with(@time_entry, location: business_time_entry_path(@business, @time_entry))
  end

  def destroy
    @time_entry.destroy
    respond_with(@office, location: business_time_entries_path(@business))
  end

  private

  def time_entry_params
    p = params.require(:time_entry).permit!
    p[:business_id] = params[:business_id]
    p = convert_meridians(p)
    p.dup
  end
end
