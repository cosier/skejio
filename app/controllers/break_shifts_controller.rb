# Responsible for managing the breaks for an individual Service Provider.
class BreakShiftsController < BusinessesController
  respond_to :json
  load_and_authorize_resource

  skip_load_resource only: [:create, :destroy]

  before_filter :set_break_shift, only: [:destroy]

  include EntryHelper

  def index
    respond_with @business, @break_shifts do |format|
      format.json { render json: @break_shifts }
    end
  end

  def show
    respond_with @business, @break_shift do |format|
      format.json { render json: @break_shift }
    end
  end

  def create
    binding.pry

    @break_shift = BreakShift.new(break_shift_params)
    @break_shift.save! if authorize! :create, @break_shift

    if params[:break_shift][:services]
      params[:break_shift][:services].each do |id|
        @break_shift.break_services.create!(
          business_id: @business.id,
          service_id: id,
          break_shift_id: @break_shift.id)
      end
    end

    if params[:break_shift][:offices]
      params[:break_shift][:offices].each do |id|
        @break_shift.break_offices.create!(
          business_id: @business.id,
          office_id: id,
          break_shift_id: @break_shift.id)
      end
    end

    respond_with @business, @break_shift do |format|
      format.json { render json: @break_shift }
    end
  end

  def update
    @break_shift.update(break_shift_params)
    respond_with @business, @break_shift do |format|
      format.json { render json: @break_shift }
    end
  end

  def destroy
    authorize! :destroy, @break_shift
    @break_shift.destroy
    respond_with @business, @break_shift
  end

  protected

  def set_break_shift
    @break_shift = BreakShift.find(params[:id])
    authorize! :read, @break_shift
  end

  def break_shift_params
    p = params.require(:break_shift).except(:services, :offices).permit!
    p[:business_id] = @business.id
    p = convert_meridians(p)
    p = convert_date_ranges(p)
    p
  end

end
