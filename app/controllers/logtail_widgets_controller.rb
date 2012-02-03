class LogtailWidgetsController < ApplicationController
  layout nil

  # FIXME
  # => add authentication!


   def create
    @widget = LogtailWidget.new()
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
    @widget = LogtailWidget.find(params[:id])
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

  def new
    # one needs to specify a system & a path to logfile for this widget
    # TODO known files should be app logfile, apache access log, tomcat catalina.out
    @systems = System.find(:all)
    @known_files = "not yet"

  end

  # tail output will be requested by logtail widgets frequently (refresh_interval)
  # named route "logtail" is used for access
  # triggers a backgroundrb job, that establishes a SSH session and writes result
  #  to tmpfiles
  # FIXME add authentication
  def tailoutput
    @system = System.find(params[:system_id])
    @filename = params[:filename]
    @refresh_interval = params[:refresh_interval]

   # TODO read from cache
   #@output = MiddleMan.worker(:hello_world_worker).ask_result("some_key")
   @output = `date` + "NOT YET"
    
    respond_to do |format|
      # html is just used for DEBUG
      format.html do
        render :text => @output
        #render :text => @output
      end
      format.json do
        render :text => @output.to_json
      end
    end
  end



 
end
