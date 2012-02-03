class LiveTickerBarWidgetsController < ApplicationController
  layout nil

  def form_step1
    # only systems with a running_service of type "CollectdService" are relevant
    all_systems = System.find(:all, :order => "name")
    @systems = []
    all_systems.each do |s|
      @systems << s if s.has_service_of_type?("CollectdService")
    end
  end

  def form_step2
    ids = params[:system_id] if params[:system_id]

    all_metrics = []
    ids.each {|id|
      system = System.find(id)
      metrics = system.collectd_scan
      all_metrics << metrics
    }
    if all_metrics.first
      @metrics = all_metrics.first
      all_metrics.each  { |a|
        metrics = []
        @metrics.each {|m| metrics << m  if a.any?{|x| x['metric'] == m['metric']}}
        @metrics = metrics
      }

      @metrics.sort! { |a,b| a['metric'].downcase <=> b['metric'].downcase }
    end
    
    if !@metrics
      respond_to do |format|
        format.json do
          render :text => "false"
        end
      end
    end
  end

  def create
    @widget = LiveTickerBarWidget.new()
    @widget.dashboard_id = params[:dashboard_id]
    @widget.preferences = ActiveSupport::JSON.decode(params[:preferences]) if params[:preferences]
    @widget.sizex = (params[:sizex]) ? params[:sizex] : nil
    @widget.sizey = (params[:sizey]) ? params[:sizey] : nil
    @widget.top = (params[:top]) ? params[:top] : @widget.top
    @widget.top = 27 if @widget.top.to_i < 27
    @widget.left = (params[:left]) ? params[:left] : @widget.left
    @widget.left = 0 if @widget.left.to_i < 0

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
    @widget = LiveTickerBarWidget.find(params[:id])
    @widget.preferences = ActiveSupport::JSON.decode(params[:preferences]) if params[:preferences]
    @widget.sizex = (params[:sizex]) ? params[:sizex] : nil
    @widget.sizey = (params[:sizey]) ? params[:sizey] : nil
    @widget.top = (params[:top]) ? params[:top] : @widget.top
    @widget.top = 27 if @widget.top.to_i < 27
    @widget.left = (params[:left]) ? params[:left] : @widget.left
    @widget.left = 0 if @widget.left.to_i < 0

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
  
  def show
    @widget = LiveTickerBarWidget.find(params[:id])

    system_id = ActiveSupport::JSON.decode(@widget.preferences['system_id'])

    @system = System.find(system_id)
    
    @metrics = ActiveSupport::JSON.decode(@widget.preferences['metrics'])

    # calculating a resolution
    # http://www.mrtg.org/rrdtool/doc/rrdfetch.en.html
    
    resolution = 60 # 5 min in seconds
    end_date = (Time.now.to_i / resolution).to_i * resolution
    start_date = end_date - 1.hours

    @last_update = @widget.get_last_values(start_date, end_date, @system)
    @data = @widget.get_series(start_date, end_date, @system, resolution)
  end


end
