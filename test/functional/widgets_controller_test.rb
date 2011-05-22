require 'test_helper'

class WidgetsControllerTest < ActionController::TestCase
  def test_index
    get :index
    assert_template 'index'
  end
  
  def test_show
    get :show, :id => Widget.first
    assert_template 'show'
  end
  
  def test_new
    get :new
    assert_template 'new'
  end
  
  def test_create_invalid
    Widget.any_instance.stubs(:valid?).returns(false)
    post :create
    assert_template 'new'
  end
  
  def test_create_valid
    Widget.any_instance.stubs(:valid?).returns(true)
    post :create
    assert_redirected_to widget_url(assigns(:widget))
  end
  
  def test_edit
    get :edit, :id => Widget.first
    assert_template 'edit'
  end
  
  def test_update_invalid
    Widget.any_instance.stubs(:valid?).returns(false)
    put :update, :id => Widget.first
    assert_template 'edit'
  end
  
  def test_update_valid
    Widget.any_instance.stubs(:valid?).returns(true)
    put :update, :id => Widget.first
    assert_redirected_to widget_url(assigns(:widget))
  end
  
  def test_destroy
    widget = Widget.first
    delete :destroy, :id => widget
    assert_redirected_to widgets_url
    assert !Widget.exists?(widget.id)
  end
end
