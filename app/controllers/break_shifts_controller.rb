class BreakShiftsController < BusinessesController
  respond_to :json
  load_and_authorize_resource

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
    @break_shift.save
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
    @break_shift.destroy
    respond_with @business, @break_shift
  end

  protected

  def break_shift_params
    p = params.require(:break_shift).permit!
    p[:business_id] = @business.id
    p = convert_meridians(p)
    p
  end

end
