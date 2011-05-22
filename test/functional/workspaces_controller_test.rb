require 'test_helper'

class WorkspacesControllerTest < ActionController::TestCase
  def test_index
    get :index
    assert_template 'index'
  end
  
  def test_show
    get :show, :id => Workspace.first
    assert_template 'show'
  end
  
  def test_new
    get :new
    assert_template 'new'
  end
  
  def test_create_invalid
    Workspace.any_instance.stubs(:valid?).returns(false)
    post :create
    assert_template 'new'
  end
  
  def test_create_valid
    Workspace.any_instance.stubs(:valid?).returns(true)
    post :create
    assert_redirected_to workspace_url(assigns(:workspace))
  end
  
  def test_edit
    get :edit, :id => Workspace.first
    assert_template 'edit'
  end
  
  def test_update_invalid
    Workspace.any_instance.stubs(:valid?).returns(false)
    put :update, :id => Workspace.first
    assert_template 'edit'
  end
  
  def test_update_valid
    Workspace.any_instance.stubs(:valid?).returns(true)
    put :update, :id => Workspace.first
    assert_redirected_to workspace_url(assigns(:workspace))
  end
  
  def test_destroy
    workspace = Workspace.first
    delete :destroy, :id => workspace
    assert_redirected_to workspaces_url
    assert !Workspace.exists?(workspace.id)
  end
end
