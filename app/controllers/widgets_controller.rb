class WidgetsController < ApplicationController
  def index
    @widgets = Widget.all
  end
  
  def show
    @widget = Widget.find(params[:id])
  end
  
  def new
    @widget = Widget.new
  end
  
  def create
    @widget = Widget.new(params[:widget])
    if @widget.save
      flash[:notice] = "Successfully created widget."
      redirect_to :back
    else
      render :action => 'new'
    end
  end
  
  def edit
    @widget = Widget.find(params[:id])
    respond_to do |format|
      format.html # views/widgets/edit.html.erb
      format.js # views/widgets/edit.js.rjs
    end
  end
  
  def update
    @widget = Widget.find(params[:id])
    if @widget.update_attributes(params[:widget])
      flash[:notice] = "Successfully updated widget."
      redirect_to :back
    else
      render :action => 'edit'
    end
  end
  
  def destroy
    @widget = Widget.find(params[:id])
    @widget.destroy
    flash[:notice] = "Successfully deleted widget."
    redirect_to :back
  end
end
