class MuninImageWidgetsController < ApplicationController
  layout nil

  def create
    @widget = MuninImageWidget.new()
    @widget.dashboard_id = params[:dashboard_id]
    @widget.preferences = ActiveSupport::JSON.decode(params[:preferences]) if params[:preferences]
#    @widget.zindex = (params[:zindex]) ? params[:zindex] : 10000
    @widget.top = (params[:left]) ? params[:top] : nil
    @widget.left = (params[:top]) ? params[:left] : nil

    widgets = Widget.find(:all, :conditions => { :dashboard_id => params[:dashboard_id] })
    max_zindex = widgets.size()
    @widget.zindex = max_zindex + 1

    respond_to do |format|
      if @widget.save
        format.json {
          ActiveRecord::Base.include_root_in_json = false
          render :text => @widget.to_json(:methods => :type)
        }
      else
        render :text => 'false'
      end
    end
  end

  def update
    @widget = MuninImageWidget.find(params[:id])
    @widget.preferences = ActiveSupport::JSON.decode(params[:preferences]) if params[:preferences]

    respond_to do |format|
      if @widget.save
        format.json {
          ActiveRecord::Base.include_root_in_json = false
          render :text => @widget.to_json(:methods => :type)
        }
      else
        format.json {render :text => 'false' }
      end
    end
  end
  
end
