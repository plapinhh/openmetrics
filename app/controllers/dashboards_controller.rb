class DashboardsController < ApplicationController
  # deactivated until proper right management is established
  #before_filter :check_master_role, :except => [ "index", "show" ]
  layout "application"
  #layout "dashboard"

  def index
    @dashboards = Dashboard.find :all, :conditions => { :temporary => false }, :order => 'name ASC'
    @temp_dashboards = Dashboard.find :all, :conditions => { :temporary => true }
    add_breadcrumb 'Dashboards overview'
  end
  
  def show
    @dashboard = Dashboard.find(params[:id])
    @dashboard_widgets = Widget.find(:all, :conditions => { :dashboard_id => @dashboard.id })

    # is a service of type CollectdService available
    @services = Service.find(:all)
    @services.each do |s|
      # s.type gives deprecation warning, type column is used for sti
      if s.class.name == "CollectdService"
        @collectd_service_available = true
      end
    end

    add_breadcrumb @dashboard.name, 'dashboard' unless @dashboard.temporary?

    respond_to do |format|
      format.json {
          @json_export = ""
          @json_export << "{"
          ActiveRecord::Base.include_root_in_json = false
          @json_export <<   '"widgets":'
          @json_export <<       @dashboard_widgets.to_json(:methods => :type)
          ActiveRecord::Base.include_root_in_json = true
          @json_export << "}" #end @json_export
          render :text => @json_export
      }
      format.html {
        # friendly urls, http://doblock.com/articles/seo-friendly-urls-for-your-rails-app-with-friendly_id
        enforce_friendly_url_for(@dashboard)
      }
    end
  end

   # IN USE for MuninImageWidget forms
  def list_only
   sort_by = params[:sort_by]
    if sort_by == nil
      sort_by = "name"
    end
    @dashboards = Dashboard.find(:all, :order => "#{sort_by} ASC, name ASC")
    respond_to do |format|
      format.html  { render :text => 'something wrong' }
      format.json  {
          @json_export = ""
          @json_export << "{"
          @json_export <<   '"dashboards":'
          ActiveRecord::Base.include_root_in_json = false
          @json_export <<       @dashboards.to_json(:only => [ :name, :id ])
          ActiveRecord::Base.include_root_in_json = true
          @json_export << "}" #end @json_export
          render :text => @json_export
      }
    end
  end
  
  def new
    @dashboard = Dashboard.new
    # this could be used for accepts_nested_attributes_for in dashboard model
    # widget = @dashboard.widgets.build

    respond_to do |format|
      format.js # views/dashboards/new.js.rjs
    end
  end
  
  def create
    @dashboard = Dashboard.new(params[:dashboard])
    if @dashboard.save
      flash[:notice] = "Successfully created dashboard."
      redirect_to @dashboard
    else
      render :action => 'new'
    end
  end
  
  def edit
    @dashboard = Dashboard.find(params[:id])
    # currently used for renaming dashboards, to access widgets have a look
    # at the show method
    #@dashboard_widgets = Widget.find(:all, :conditions => { :dashboard_id => @dashboard.id })
    respond_to do |format|
#      format.html # views/dashboards/edit.html.erb
      format.js # views/dashboards/edit.js.rjs
    end

  end
  
  def update
    @dashboard = Dashboard.find(params[:id])
    if @dashboard.update_attributes(params[:dashboard])
      flash[:notice] = "Successfully updated dashboard."
#      redirect_to @dashboard
        redirect_to :action => "index"
    else
      flash[:error] = "Could not update dashboard."
      redirect_to :action => "index"
#      render :action => 'edit'
    end
  end
  
  def destroy
    @dashboard = Dashboard.find(params[:id])
    @dashboard.destroy
    flash[:notice] = "Successfully destroyed dashboard."
    redirect_to :action => "index"
  end
end
