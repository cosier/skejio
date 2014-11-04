class ManageBusinessesController < ApplicationController
  before_action :set_business, only: [:show, :edit, :update, :destroy]
  respond_to :html, :xml, :js

  before_action :set_current_navigation

  layout 'super_console'

  def index
    @businesses = ManageBusiness.all
    respond_with(@businesses)
  end

  def show
    respond_with(@business)
  end

  def new
    @business = ManageBusiness.new
    respond_with(@business)
  end

  def edit
  end

  def create
    @business = ManageBusiness.new(business_params)
    @business.save
    respond_with(@business)
  end

  def update
    @business.update(business_params.permit!)
    respond_with(@business)
  end

  def destroy
    @business.destroy
    respond_with(@business)
  end

  private
    def set_business
      @business = ManageBusiness.find(params[:id])
    end

    def set_current_navigation
      @current_sidebar = :businesses
    end

    def business_params
      params[:manage_business]
    end
end
