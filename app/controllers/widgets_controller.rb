class WidgetsController < ApplicationController
  #layout "application", :except => :edit#widget-form
  #layout "application"
  #layout "dashboard"

#  def index
#    @widgets = Widget.all
#  end
#

  # show is used if widget has :preference refresh_interval 
  def show
    @widget = Widget.find(params[:id])
    respond_to do |format|
      format.html # index.html.erb
      format.json {
          ActiveRecord::Base.include_root_in_json = false
          render :text => @widget.to_json(:methods => :type)
        }
    end
  end
  
  def update
    @widget = Widget.find(params[:id])
    @widget.dashboard_id = params[:dashboard_id] if params[:dashboard_id]
    @widget.top = (params[:top]) ? params[:top] : @widget.top
    @widget.top = 27 if @widget.top.to_i < 27
    @widget.left = (params[:left]) ? params[:left] : @widget.left
    @widget.left = 0 if @widget.left.to_i < 0
    @widget.sizex = params[:sizex] if (params[:sizex])
    @widget.sizey = params[:sizey] if (params[:sizey])

    zindex_old = @widget.zindex;
    widgets_to_aktualize = Widget.find_all_by_dashboard_id(@widget.dashboard_id, :conditions => "zindex > " + zindex_old.to_s ) if params[:dashboard_id]

    if (params[:zindex] && params[:dashboard_id])
      @widget.zindex = Widget.find(:all, :conditions => { :dashboard_id => @widget.dashboard_id }).size()
    end

    respond_to do |format|
      if @widget.save
        if (widgets_to_aktualize != nil)
          widgets_to_aktualize.each do |w|
            w.zindex = w.zindex - 1
            w.save
          end
        end

        format.json {
          ActiveRecord::Base.include_root_in_json = false
          render :text => @widget.to_json(:methods => :type)
        }
      else
        format.json {render :text => 'false' }
      end
    end
  end
  
  def destroy
    ids = params[:ids] if params[:ids]
    ids.each do |id|
      widget = Widget.find(id)
      widget.destroy
    end
    respond_to do |format|
        format.json {render :text => 'true' }
    end
  end


end
