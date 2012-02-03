class TextWidgetsController < ApplicationController
  layout nil

  def create
    @widget = TextWidget.new()
    @widget.dashboard_id = params[:dashboard_id]
    @widget.preferences = ActiveSupport::JSON.decode(params[:preferences]) if params[:preferences]
    @widget.sizex = (params[:sizex]) ? params[:sizex] : nil
    @widget.sizey = (params[:sizey]) ? params[:sizey] : nil
    #    @widget.zindex = (params[:zindex]) ? params[:zindex] : 10000

    widgets = Widget.find(:all, :conditions => { :dashboard_id => params[:dashboard_id] })
    max_zindex = widgets.size()
    @widget.zindex = max_zindex + 1

    respond_to do |format|
      if @widget.save
        format.json {
          #ActiveRecord::Base.include_root_in_json = true
          ActiveRecord::Base.include_root_in_json = false
          render :text => @widget.to_json(:methods => :type)
          #ActiveRecord::Base.include_root_in_json = false
        }

      else
        render :text => 'false'
      end
    end
  end

  def update
    @widget = TextWidget.find(params[:id])
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
