require 'test_helper'

class ManageBusinessesControllerTest < ActionController::TestCase
  setup do
    @business = manage_businesses(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:manage_businesses)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create manage_business" do
    assert_difference('ManageBusiness.count') do
      post :create, manage_business: {  }
    end

    assert_redirected_to manage_business_path(assigns(:manage_business))
  end

  test "should show manage_business" do
    get :show, id: @business
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @business
    assert_response :success
  end

  test "should update manage_business" do
    patch :update, id: @business, manage_business: {  }
    assert_redirected_to manage_business_path(assigns(:manage_business))
  end

  test "should destroy manage_business" do
    assert_difference('ManageBusiness.count', -1) do
      delete :destroy, id: @business
    end

    assert_redirected_to manage_businesses_path
  end
end
