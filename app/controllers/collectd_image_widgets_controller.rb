class CollectdImageWidgetsController < ApplicationController
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

      @metric_presets = []
      CollectdPreset.create.get_all_presets.each {|preset|
#        @metric_presets << preset[0] if preset[1].is_valid && @metrics.any?{|x| x['metric'].match(/#{preset[1].get_filter}/)}
        @metric_presets << preset[0] if @metrics.any?{|x| x['metric'].match(/#{preset[1].get_filter}/)}
      }

      @metrics.sort! { |a,b| a['metric'].downcase <=> b['metric'].downcase }
    end
    if !(@metric_presets and @metric_presets)
      respond_to do |format|
        format.json do
          render :text => "false"
        end
      end
    end
  end

  def create
    @widget = CollectdImageWidget.new()
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
    @widget = CollectdImageWidget.find(params[:id])
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
        format.json {render :text => 'false' }
      end
    end
  end

  def collectd_data
    @widget = CollectdImageWidget.find(params[:id])

    system_ids = ActiveSupport::JSON.decode(@widget.preferences['system_id'])
    start_date, end_date = @widget.get_start_end_dates
    preset = @widget.get_preset

    @result = Hash.new
    @result[:events] = @widget.get_events(start_date, end_date, system_ids)

    @result[:options] = Hash.new
    @result[:options][:yaxis] = Hash.new
#    @result[:options][:yaxis][:min] = 0
    @result[:options][:yaxis][:tickFormatter] = (preset && preset.get_unit) || @widget.preferences['tickFormatter'] || "value"

    @result[:series] = Array.new
    
    system_ids.each { |system_id|
      @result[:series] += @widget.get_series(start_date, end_date, system_id)
    }

    respond_to do |format|
      format.html
      format.json do
        render :json => @result
      end
    end
  end

end
