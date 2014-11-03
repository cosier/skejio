class BusinessesController < ApplicationController

  before_action :authenticate_user!

  def show
    @business = Business.where(id: params[:id]).first

    if @business.nil?
      return redirect_to "/", alert: "Business not found"
    end

    unless @business.valid_staff? current_user
      return redirect_to "/", alert: "You are not authorized for that Business"
    end

  end
end
