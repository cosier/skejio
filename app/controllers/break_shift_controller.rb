class BreakShiftController < BusinessesController
  respond_to :json
  load_and_authorize_resource

  def index
    respond_with @break_shifts.order(:created_at => :desc).limit(30).to_a
  end

  def show
    respond_with @break_shifts.find(params[:id])
  end

  def create
    respond_with @break_shifts.create(params[:number])
  end

  def update
    respond_with @break_shifts.update(params[:id], params[:number])
  end

  def destroy
    respond_with @break_shifts.destroy(params[:id])
  end

end
