class TwillioTestsController < ApplicationController
  before_action :set_twillio_test, only: [:show, :edit, :update, :destroy]

  def index
    @twillio_tests = TwillioTest.all
    respond_to do |format|
      format.html {}
    end
    
  end

  def show
    respond_with(@twillio_test)
  end

  def new
    @twillio_test = TwillioTest.new
    respond_to do |format|
      format.html {}
    end
  end

  def edit
  end

  def create
    @twillio_test = TwillioTest.new(twillio_test_params)
    @twillio_test.send_sms
    @twillio_test.save
    respond_to do |format|
      format.html { redirect_to twillio_tests_path}
    end
  end

  def update
    @twillio_test.update(twillio_test_params)
    respond_to do |format|
      format.html { redirect_to twillio_tests_path}
    end
  end

  def destroy
    @twillio_test.destroy
    respond_with(@twillio_test)
  end

  private
    def set_twillio_test
      @twillio_test = TwillioTest.find(params[:id])
    end

    def twillio_test_params
      params.require(:twillio_test).permit(:to_number, :body)
    end
end
