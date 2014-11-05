require 'test_helper'

class BusinessOfficesControllerTest < ActionController::TestCase
  setup do
    @business_office = business_offices(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:business_offices)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create business_office" do
    assert_difference('BusinessOffice.count') do
      post :create, business_office: { business_id: @business_office.business_id, location: @business_office.location, name: @business_office.name }
    end

    assert_redirected_to business_office_path(assigns(:business_office))
  end

  test "should show business_office" do
    get :show, id: @business_office
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @business_office
    assert_response :success
  end

  test "should update business_office" do
    patch :update, id: @business_office, business_office: { business_id: @business_office.business_id, location: @business_office.location, name: @business_office.name }
    assert_redirected_to business_office_path(assigns(:business_office))
  end

  test "should destroy business_office" do
    assert_difference('BusinessOffice.count', -1) do
      delete :destroy, id: @business_office
    end

    assert_redirected_to business_offices_path
  end
end
