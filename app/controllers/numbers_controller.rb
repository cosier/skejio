class NumbersController < ApplicationController

  load_and_authorize_resource :business,
    id_param: :business_id

  # Load Numbers
  load_and_authorize_resource

  layout 'business_console'

  def index
    @current_sidebar = :numbers
    @numbers = Number.all
    respond_with(@numbers)
  end

  def show
    respond_with(@number)
  end

  def new
    @number = Number.new
    respond_with(@number)
  end

  def edit
  end

  def create
    @number = Number.new(number_params)
    @number.save
    respond_with(@number)
  end

  def update
    @number.update(number_params)
    respond_with(@number)
  end

  def destroy
    @number.destroy
    respond_with(@number)
  end


  def search_number
    @sub_account = @business.sub_account
    respond_to do |format|
      format.html {}
    end
  end

  def search_numbers
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

  def buy_phone_number
    @sub_account = @business.sub_account
    phone_number = @sub_account.buy_phone_number(params[:num])
    @sub_account.number = phone_number
    @sub_account.save

    respond_to do |format|
      format.html { redirect_to business_subaccounts_path(@business) , :notice => "You successfully puchased #{phone_number}"}
    end
  end

  def send_sms
    @sub_account = @business.sub_account
    @sub_account.send_sms(params[:message])

    respond_to do |format|
      format.html { redirect_to business_subaccounts_path(@business), :notice => "Message has been sent successfully #{params[:message][:to]}"}
    end

  end

  def make_a_call
    @sub_account = @business.sub_account
    @sub_account.make_a_call(params[:info])

    respond_to do |format|
      format.html {redirect_to business_subaccounts_path(@business), :notice => "Call will be made in few secs to #{params[:info][:to]}"}
    end
  end

  private
    def set_number
      @number = Number.find(params[:id])
    end

    def number_params
      params.require(:number).permit(:sub_account_id, :number, :sid, :sauth_token)
    end
end
