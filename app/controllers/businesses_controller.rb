class BusinessesController < SecureController

  before_action :authenticate_user!

  before_action :get_business
  before_action :validate_business_permissions

  layout 'business_console'

  include BusinessHelper

  def dashboard
    @current_sidebar = :dashboard
  end

  def pending
    @current_sidebar = :pending
    redirect_to business_slug_path(@business) if @business.is_active?
  end


  def subaccounts
    @sub_account = @business.phones[0]
    respond_to do |format|
      format.html {}
    end
  end


  def new_subaccount
    @sub_account = @business.phones.new
    respond_to do |format|
      format.html {}
    end
  end

  def create_subaccount
    sub_account = @business.create_tw_subaccount
    @sub_account = @business.phones.new(sub_account)
    @sub_account.save
    respond_to do |format|
      format.html { redirect_to business_subaccounts_path(@business.slug) }
    end
  end

  def search_number
    @sub_account = @business.phones[0]
    respond_to do |format|
      format.html {}
    end
  end

  def search_numbers
    @sub_account = @business.phones[0]
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
    @sub_account = @business.phones[0]
    phone_number = @sub_account.buy_phone_number(params[:num])
    @sub_account.number = phone_number
    @sub_account.save
    respond_to do |format|
      format.html { redirect_to business_subaccounts_path(@business.slug) , :notice => "You successfully puchased #{phone_number}"}
    end
  end


  def send_sms 
    @sub_account = @business.phones[0]
    @sub_account.send_sms(params[:message])

    respond_to do |format|
      format.html {redirect_to business_subaccounts_path(@business.slug), :notice => "Message has been sent successfully #{params[:message][:to]}"}
    end

  end

  def make_a_call
    @sub_account = @business.phones[0]
    @sub_account.make_a_call(params[:info])
    
    respond_to do |format|
      format.html {redirect_to business_subaccounts_path(@business.slug), :notice => "Call will be made in few secs to #{params[:info][:to]}"}
    end
  end




  private

  def get_business
    @business = Business.where(slug: params[:slug]).first if params[:slug]
  end

  def validate_business_permissions

    # Check for invalid businesses
    return redirect_to "/", alert: "Business not found" if @business.nil?

    # Check for permission of the current_user logged in against the business
    unless @business.valid_staff? current_user
      return redirect_to "/", alert: "You are not authorized for that Business"
    end

    # Check that the business has been approved (is_active)
    if not @business.is_active? and params[:action] != "pending"
      return redirect_to business_pending_path(slug: @business.slug)
    end

  end

end
