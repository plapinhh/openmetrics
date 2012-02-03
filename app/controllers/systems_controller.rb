class SystemsController < ApplicationController
  before_filter :check_master_role, :except => [ :index, :show, :generate_dashboard ]
  layout "application", :only => [:index, :show, :edit, :new]

  # GET /systems
  # GET /systems.xml
  def index

    @systems = System.find(:all, :include => [:system_group_maps, :running_services])
    @services = Service.find :all, :order => 'name ASC'
    # sort running_services by service.name
    # looks ugly, as neither the used association doesnt allow direct sorting nor find can nest :include & :order
    @systems.each do |s|
        unless s.running_services.empty? 
          s.running_services.sort! {|a,b| @services[@services.index{|x|x.id==a.service_id}.to_i].name <=> @services[@services.index{|x|x.id==b.service_id}.to_i].name}
        end
    end

    add_breadcrumb 'Systems overview'

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @systems }
      format.csv  {
          @csv_export = "";
          @sep = "|"
          # create headline
          if params[:include_headline] == "true"
            @csv_export << "system.name#{@sep}system.ip#{@sep}system.fqdn#{@sep}system.description#{@sep}system.environment#{@sep}system.operating_system#{@sep}system.operating_system_flavour\n"
          end
          @systems.each do |system|
            @csv_export << "#{system.name}#{@sep}#{system.ip}#{@sep}#{system.fqdn}#{@sep}#{system.description}#{@sep}#{system.environment}#{@sep}#{system.operating_system}#{@sep}#{system.operating_system_flavour}\n"
          end
          send_data(@csv_export,
                    :type => 'text/csv; charset=utf-8; header=present',
                    :filename => "systemslist.csv")

        } # format csv
      format.json {
          @json_export = ""
          @json_export << "{"
          @json_export <<   '"total": "'<< "#{@systems.size()}" <<'", '
          @json_export <<   '"page": "1", '
          @json_export <<   '"records": "-1", '
          ActiveRecord::Base.include_root_in_json = false
          @json_export <<   '"systems":'
          @json_export <<       @systems.to_json(:only => [:id, :name, :ip, :fqdn, :description, :service_id], :include => [:system_group_maps, :running_services])
          @json_export <<   ','
          @json_export <<   '"userdata":{'
            @json_export <<     '"services":'
            @json_export <<         @services.to_json()
            @json_export <<     ','
            @json_export <<     '"system_groups":'
            @json_export <<         SystemGroup.find(:all).to_json()
          @json_export <<   '}' #end userdata
          ActiveRecord::Base.include_root_in_json = true
          @json_export << "}" #end @json_export
           render :text => @json_export
        }
    end
  end

  # IN USE for MuninImageWidget forms
  def list_only
   sort_by = params[:sort_by]
    if sort_by == nil
      sort_by = "name"
    end
    @systems = System.find(:all, :order => "#{sort_by} ASC, name ASC")
    respond_to do |format|
      format.html  { render :text => 'something wrong' }
      format.json  {
          @json_export = ""
          @json_export << "{"
          @json_export <<   '"systems":'
          ActiveRecord::Base.include_root_in_json = false
          @json_export <<       @systems.to_json(:only => [ :name, :id, :munin_group ])
          ActiveRecord::Base.include_root_in_json = true
          @json_export << "}" #end @json_export
          render :text => @json_export
      }
    end
  end


  # GET /systems/1
  # GET /systems/1.xml
  def show
    @system = System.find(params[:id], :include => [:system_group_maps, :running_services])
    @services = Service.find :all
    # sort running_services by service.name
    # looks ugly, as neither the used association doesnt allow direct sorting nor find can nest :include & :order
    unless @system.running_services.empty?
      @system.running_services.sort! {|a,b| @services[@services.index{|x|x.id==a.service_id}.to_i].name <=> @services[@services.index{|x|x.id==b.service_id}.to_i].name}
    end

    add_breadcrumb @system.name, 'system'

    @system_groups = SystemGroup.find(:all)
    @system_variables = SystemVariable.find(:all, :conditions => { :system_id => @system.id})
    # TODO issues currently consists of latest alerts only; add events, changes and other
    @recent_alerts = @system.recent_alerts
    @issues_days = @recent_alerts.group_by { |t| t.created_at.beginning_of_day }
    #@issues = []
    #@issues += @system.recent_alerts
    # TODO a struct may suit better
    #    Fruit = Struct.new(:name, :calories)
    #
    #fruits = [
    #  Fruit.new("apple", 100),
    #  Fruit.new("banana", 200),
    #  Fruit.new("kumquat", 225),
    #  Fruit.new("orange", 90)
    #]
    #
    #fruits.each {|f| eat(f.name, f.calories)}
    #    
    
    @gvsvg = @system.generate_relationsgraph
    
#    @system_variables.sort! do |x,y|
#      x.name <=> y.name
#    end

    # TEST! DO NEVER TOUCH THIS!
    # @keys= parse_authorized_keys(read_current_keys(@system.ip))

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @system }
      format.json  {
          render :text => @system.to_json(:except => [ :created_at, :updated_at ], :include => [:system_group_maps , :running_services])
      }
    end
  end

  def edit
    @system = System.find(params[:id], :include => [:system_group_maps, :running_services ])
    @services = Service.find(:all)
    @system_groups = SystemGroup.find(:all)
    @system_variables = SystemVariable.find(:all, :conditions => { :system_id => @system.id})
    @collectd_plugins = CollectdPlugin.find(:all)

    add_breadcrumb "edit #{@system.name}", "system"

    respond_to do |format|
      format.html # edit.html.erb
      format.xml  { render :xml => @system }
    end
  end

  # generates a new dashboard and places several widgets
  # currently used to see a systems basic metrics
  def generate_dashboard
    dashboard = Dashboard.new()
    dashboard.create_dashboard_for_system(params[:id])

    respond_to do |format|
        ActiveRecord::Base.include_root_in_json = false
        format.json  { render :text => dashboard.to_json(:except => [ :created_at, :updated_at ])}
        ActiveRecord::Base.include_root_in_json = true
    end
  end


  # working against RESTful Design, since lack of time
  # NOTE: REFACTOR THIS SOON
#  def history
#    # get current state
#    @system = System.find(params[:id])
#    @current_running_services = RunningService.find(:all, :conditions => { :system_id => @system.id})
#
#    #get history entries for current system
#    @previous_versions = SystemHistory.find(:all, :conditions => { :system_id => @system.id})
#    @previous_running_services = RunningServiceHistory.find(:all, :conditions => { :system_id => @system.id})
#    @previous_services = []
#    unless @previous_running_services == nil
#      @previous_running_services.each { |rs|  @previous_services << ServiceHistory.find(:first, :conditions => {:service_id => rs.service_id} ) }
#    end
#
#    @previous_services.uniq! # remove duplicate services in list
#
#    @history = [] # the full history object
#    @previous_versions.each { |e| @history << e unless e == nil}
#    @previous_running_services.each { |e| @history << e unless e == nil}
#    @previous_services.each { |e| @history << e unless e == nil}
#
#
#    if params[:timestamp] != nil
#      timestamp = Time.at(params[:timestamp].to_f)
#    else
#      timestamp = @system.updated_at
#    end
#    @old_services = @system.get_services_state_at(timestamp)
#    @old_running_services = @system.get_running_services_at(timestamp)
#    @old_system = @system.get_state_at(timestamp)
#    logger.debug @old_system.inspect
#
#    @history.sort! { |x,y| x.created_at <=> y.created_at}
#    @history.reverse!
#    respond_to do |format|
#      format.html # history.html.erb
#      format.xml  { render :xml => @system }
#      format.js do
#        render :update do |page|
#          page.replace_html :container, :partial => 'oldsystem'
#        end
#      end
#    end
#  end




  # POST /systems
  # POST /systems.xml
  def create
    @system = System.new

     # HACK! DO NOT TOUCH; NEED TO REFACTOR WHOLE CONTROLLER!
     # WTF? unhack please! that one prevents systems from beeing created
#    @system.last_change_user_id = @current_user.id
    # /HACK!


    respond_to do |format|
      if @system.update_attributes(params[:system])
        if params[:create_running_services]
          for service_id in params[:create_running_services] do
              new_rs = RunningService.new
              new_rs[:service_id] = service_id
              new_rs[:system_id] = @system.id
              new_rs[:comment] = 'comment...'
              new_rs.save
          end
        end

        if params[:add_system_group_maps]
          for sgm_id in params[:add_system_group_maps] do
              sg = SystemGroupMap.find_by_id sgm_id
              new_sgm = SystemGroupMap.new  
              new_sgm[:system_group_id] = sg.system_group_id
              new_sgm[:system_id] = @system.id
              new_sgm.save
          end
        end
        
        # parameter equals system id to clone from or false
        #
        # cloning here is a bit awkward: 
        #   1) fetch running services and attached collectd plugins from system to clone from
        #   2) for every attached collectd plugin try to find a matching running service of the new system
        #   3) if running services are matching, attach collectd plugin
        # FIXME cloning may lead to unexpected result if multiple running services of same service kind belong to one system
        unless params[:clone_metric_plugins] == "false"
          s_to_clone = System.find_by_id "#{params[:clone_metric_plugins]}", :include => [:running_services => :service ] 
          s_to_clone.running_services.each do |rs|
            rcps = RunningCollectdPlugin.find :all, :conditions => {:running_service_id => rs.id}, :include => :collectd_plugin
            rcps.each do |rcp| 
              @system.running_services.each do |srs|
                if srs.service_id == rs.service_id
                  #logger.info "matching (running-)service found"
                  new_rcp = RunningCollectdPlugin.new
                  new_rcp[:running_service_id] = srs.id
                  new_rcp[:collectd_plugin_id] = rcp.collectd_plugin.id
                  new_rcp.save
                  stdout = enable_collectd_plugin(rcp.collectd_plugin, @system)
                  puts "DEBUG STDOUT #{@system.ip}:\n#{stdout}" unless stdout.nil?
                end
              end
            end            
          end
        end
       
        format.json {
          render :text => @system.to_json(:except => [ :created_at, :updated_at ], :include => { :running_services => { :include => :service }})
        }
      else
        format.json {render :text => 'false'}
      end
    end
  end

  # PUT /systems/1
  # PUT /systems/1.xml
  def update
    @system = System.find(params[:id])

    # HACK! DO NOT TOUCH; NEED TO REFACTOR WHOLE CONTROLLER!
    @system.last_change_user_id = @current_user.id
    # /HACK!

    if params[:create_running_services]
      @create_running_services = params[:create_running_services]
      for service_id in @create_running_services do
          @new_running_service = RunningService.new
          @new_running_service[:service_id] = service_id
          @new_running_service[:system_id] = params[:id]
          @new_running_service[:comment] = 'comment...'
          # HACK! DO NOT TOUCH; NEED TO REFACTOR WHOLE CONTROLLER!
          @new_running_service.last_change_user_id = @current_user.id
          # /HACK!
          @new_running_service.save
      end
    end

    if params[:destroy_running_services]
      @destroy_running_services = params[:destroy_running_services]
      for rs in @destroy_running_services do
          @destroy_running_service = RunningService.find(rs)
          @destroy_running_service.destroy
      end
    end

    if params[:add_system_group_maps]
      @add_system_group_maps = params[:add_system_group_maps]
      for sg in @add_system_group_maps do
          @add_system_group_map = SystemGroupMap.new
          @add_system_group_map[:system_group_id] = sg
          @add_system_group_map[:system_id] = params[:id]
          @add_system_group_map.save
      end
    end

    if params[:destroy_system_group_maps]
      @destroy_system_group_maps = params[:destroy_system_group_maps]
      for sgm in @destroy_system_group_maps do
          @destroy_system_group_map = SystemGroupMap.find(sgm)
          @destroy_system_group_map.destroy
      end
    end

    # FIXME do not allow to save a collectd_plugin to the same running_service multiple times
    if params[:add_running_collectd_plugins]
      @add_running_collectd_plugins = params[:add_running_collectd_plugins]
      for rs_cp in @add_running_collectd_plugins do
        rs_cp =  @add_running_collectd_plugins[rs_cp[0]]
        @add_running_collectd_plugin = RunningCollectdPlugin.new
        @add_running_collectd_plugin[:collectd_plugin_id] = rs_cp['collectd_plugin']
        @add_running_collectd_plugin[:running_service_id] = rs_cp['running_service']
        # before saving we want to install the configuration via sftp and restart collectd
        @collectd_plugin = CollectdPlugin.find_by_id(rs_cp['collectd_plugin'])
        stdout = enable_collectd_plugin(@collectd_plugin, @system)
        puts "DEBUG STDOUT #{@system.ip}:\n#{stdout}" unless stdout.nil?
        @add_running_collectd_plugin.save
      end
    end

    if params[:remove_running_collectd_plugins]
      @remove_running_collectd_plugins = params[:remove_running_collectd_plugins]
      for rcp in @remove_running_collectd_plugins do
        @destroy_running_collectd_plugin = RunningCollectdPlugin.find(rcp)
        @collectd_plugin = CollectdPlugin.find_by_id(@destroy_running_collectd_plugin.collectd_plugin_id)
        stdout = disable_collectd_plugin(@collectd_plugin, @system)
        puts "DEBUG STDOUT #{@system.ip}:\n#{stdout}" unless stdout.nil?
        @destroy_running_collectd_plugin.destroy
      end
    end

    respond_to do |format|
      if params[:system]
        if @system.update_attributes(params[:system])
          format.html {
            redirect_to :action => "edit"
            }
#          flash[:notice] = "The system has been saved!"
          format.json  {
            render :text => @system.to_json(:except => [ :created_at, :updated_at ], :include => [:system_group_maps , :running_services])
          }
        else
          format.html { redirect_to :action => "edit" }
          format.json {render :text => 'false'}
        end
      end
    end
  end

  # DELETE /systems/1
  # DELETE /systems/1.xml
  def destroy
    # TODO destroy running_services aswell
    @system = System.find(params[:id])

    respond_to do |format|
      if @system.destroy
        # js is used for jqgrid
        format.json {render :text => 'true'}
        # when deleting system from show method
        format.xml  {
          flash[:notice] = "Successfully destroyed system."
          redirect_to :action => "index"  }
      else
        format.json {render :text => 'false'}
      end
    end
  end

  #  (canvas tryout)
  def canvas
    
  end
  
  
  def new
    add_breadcrumb "Create a new system"
    @system = System.new
  end
  
  # POST /systemscan
  # initiates backgroundrb IpLookupWorker to start nmap scan on given target
  # creates an IpLookup object with associated use
  # TODO add authentication
  # TODO filter input and format for nmap usage  
  #
  # returns a string that can be used to lookup scanresults from memcache
  def scan
    target = params[:target] 
    ip = target
    i = IpLookup.new
    i.user_id = @current_user.id
    i.target = target
    i.save
    my_worker_key = session[:session_id]
    puts "DEBUG #{my_worker_key}"
    hash=((rand * 65535)).to_i.to_s(16).upcase.rjust(4,'0') # create a random 4 character BASE-16 hash
    my_job_key = @current_user.id.to_s + hash
    MiddleMan.new_worker(:worker => :ip_lookup_worker, :worker_key => my_worker_key)
    i.job_key = my_job_key
    i.scanresult = '["in progress"]' #json
    i.save
    MiddleMan.worker(:ip_lookup_worker,"#{my_worker_key}").async_scan_services(:arg => {:ip => ip, :job_key => my_job_key})
    respond_to do |format|
      format.html {render :text => "#{my_job_key}"}
    end
#    render :nothing => true
  end
  
  # this method will be called frequently by rjs to obtain process on system scan
  def scanresult
    job_key = params[:job_key]
    my_worker_key = session[:session_id]
    
    puts "DEBUG #{my_worker_key}"
    result = MiddleMan.worker(:ip_lookup_worker,"#{my_worker_key}").ask_result("#{job_key}")
    respond_to do |format|
      format.json {render :text => result}
    end
  end
  
end