class AlertWidgetsController < ApplicationController
  layout nil

  # FIXME
  # => add authentication!


   def create
    @widget = AlertWidget.new()
    @widget.dashboard_id = params[:dashboard_id] if params[:dashboard_id]
    @widget.preferences = ActiveSupport::JSON.decode(params[:preferences]) if params[:preferences]
    @widget.sizex = (params[:sizex]) ? params[:sizex] : 500
    @widget.sizey = (params[:sizey]) ? params[:sizey] : 500
    @widget.top = (params[:top]) ? params[:top] : 75
    @widget.left = (params[:left]) ? params[:left] : 25
    @widget.zindex = (params[:zindex]) ? params[:zindex] : 10000

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
    @widget = AlertWidget.find(params[:id])
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
