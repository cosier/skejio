require 'test_helper'

class ManageUsersControllerTest < ActionController::TestCase
  setup do
    @manage_user = manage_users(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:manage_users)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create manage_user" do
    assert_difference('ManageUser.count') do
      post :create, manage_user: {  }
    end

    assert_redirected_to manage_user_path(assigns(:manage_user))
  end

  test "should show manage_user" do
    get :show, id: @manage_user
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @manage_user
    assert_response :success
  end

  test "should update manage_user" do
    patch :update, id: @manage_user, manage_user: {  }
    assert_redirected_to manage_user_path(assigns(:manage_user))
  end

  test "should destroy manage_user" do
    assert_difference('ManageUser.count', -1) do
      delete :destroy, id: @manage_user
    end

    assert_redirected_to manage_users_path
  end
end
