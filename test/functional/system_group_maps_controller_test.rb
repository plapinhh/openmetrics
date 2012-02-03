require 'test_helper'

class SystemGroupMapsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:system_group_maps)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create system_group_map" do
    assert_difference('SystemGroupMap.count') do
      post :create, :system_group_map => { }
    end

    assert_redirected_to system_group_map_path(assigns(:system_group_map))
  end

  test "should show system_group_map" do
    get :show, :id => system_group_maps(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => system_group_maps(:one).to_param
    assert_response :success
  end

  test "should update system_group_map" do
    put :update, :id => system_group_maps(:one).to_param, :system_group_map => { }
    assert_redirected_to system_group_map_path(assigns(:system_group_map))
  end

  test "should destroy system_group_map" do
    assert_difference('SystemGroupMap.count', -1) do
      delete :destroy, :id => system_group_maps(:one).to_param
    end

    assert_redirected_to system_group_maps_path
  end
end
