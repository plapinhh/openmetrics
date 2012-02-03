class HalloWorldWidgetsController < ApplicationController
  layout nil

  def create
    @widget = HalloWorldWidget.new()
    @widget.dashboard_id = params[:dashboard_id] if params[:dashboard_id]
    @widget.preferences = ActiveSupport::JSON.decode(params[:preferences]) if params[:preferences]
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
    @widget = HalloWorldWidget.find(params[:id])
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
