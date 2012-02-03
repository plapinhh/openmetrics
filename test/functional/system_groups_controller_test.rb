require 'test_helper'

class SystemGroupsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:system_groups)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create system_group" do
    assert_difference('SystemGroup.count') do
      post :create, :system_group => { }
    end

    assert_redirected_to system_group_path(assigns(:system_group))
  end

  test "should show system_group" do
    get :show, :id => system_groups(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => system_groups(:one).to_param
    assert_response :success
  end

  test "should update system_group" do
    put :update, :id => system_groups(:one).to_param, :system_group => { }
    assert_redirected_to system_group_path(assigns(:system_group))
  end

  test "should destroy system_group" do
    assert_difference('SystemGroup.count', -1) do
      delete :destroy, :id => system_groups(:one).to_param
    end

    assert_redirected_to system_groups_path
  end
end
