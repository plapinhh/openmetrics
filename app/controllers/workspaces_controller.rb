class WorkspacesController < ApplicationController
  #include Apotomo::ControllerMethods

  def index
    @workspaces = Workspace.all
  end
  
  def show
    @workspace = Workspace.find(params[:id])
    @workspace_widgets = Widget.find(:all, :conditions => { :workspace_id => @workspace.id })

    # define apotomo widget tree
    # one can use the "type" and "id" attribute from widget object to generate ids
    # TODO create ids from database widgets
    #use_widgets do |root|
    #  root << widget(:notification_widget, 'in-notification-widget')
    #  root << widget(:example_widget, 'my_example_widget')
    #end

    #flash.now[:error] = "ERROR from workspace: #{params[:id]}"
    #flash.now[:notice] = "Hy!"
    #flash.now[:notice2] = "Have you ever heard of..."
    # flash.now[:error2] = "something definitly went wrong..."
  end
  
  def new
    @workspace = Workspace.new
    widget = @workspace.widgets.build
  end
  
  def create
    @workspace = Workspace.new(params[:workspace])
    if @workspace.save
      flash[:notice] = "Successfully created workspace."
      redirect_to @workspace
    else
      render :action => 'new'
    end
  end
  
  def edit
    @workspace = Workspace.find(params[:id])
    respond_to do |format|
      format.html # views/workspaces/edit.html.erb
      format.js # views/workspaces/edit.js.rjs
    end
  end
  
  def update
    @workspace = Workspace.find(params[:id])
    if @workspace.update_attributes(params[:workspace])
      flash[:notice] = "Successfully updated workspace."
      redirect_to @workspace
    else
      render :action => 'edit'
    end
  end
  
  def destroy
    @workspace = Workspace.find(params[:id])
    @workspace.destroy
    flash[:notice] = "Successfully destroyed workspace."
    redirect_to workspaces_url
  end
end
