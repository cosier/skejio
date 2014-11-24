class NumbersController < BusinessesController

  # Load Numbers via CanCan factory
  load_and_authorize_resource

  layout 'business_console'

  sidebar  :numbers

  def index
    @numbers = Number.business(@business)
    authorize! :read, Number

    respond_with(@business, @numbers)
  end

  def show
    respond_with(@business, @number)
  end

  def new
    @sub_account = @business.sub_account
    respond_to do |format|
      format.html {}
    end
  end

  def edit
  end

  def create
    @number = Number.new(number_params)
    @number.save
    respond_with(@business, @number)
  end

  def update
    @number.update(number_params)
    respond_with(@business, @number)
  end

  def destroy
    @number.destroy
    respond_with(@business, @number)
  end

  def search
    @sub_account = @business.sub_account

    search_params = {}

    %w[in_postal_code near_number contains].each do |p|
      search_params[p] = params[:search][p] unless params[:search][p].nil? || params[:search][p].empty?
    end

    @numbers = @sub_account.search_numbers(search_params)

    respond_to do |format|
      format.js {}
    end
  end

  def buy_number

    begin
      @number = @business.sub_account.buy_number(params[:number])
      @success = true

    rescue Twilio::REST::RequestError => e
      @success = false
      logger.error(e.message)
      return redirect_to new_business_number_path(@business),
        :alert => "Sorry, the Number #{params[:number]} is no longer available."
    end
    
    path = business_numbers_path(@business)

    respond_to do |format|
      format.html { 
        if @success
          redirect_to path , :success => "You successfully puchased #{params[:number]}"
        else
          redirect_to path , :alert => "Oops, something happened. Please try again or Contact Support, Thanks!"
        end
      }

      format.json {
        render json: { success: @success, number: @number }
      }
    end
  end


  private

  def number_params
    params.require(:number).permit(:sub_account_id, :sid, :auth_token, :office_id)
  end
end
