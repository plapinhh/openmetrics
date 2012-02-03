class CollectdServicesController < ApplicationController
  before_filter :check_master_role
  # GET /services
  # GET /services.xml
  def index
    sort_by = params[:sort_by]
    if sort_by == nil
      sort_by = "name"
    end
    @services = CollectdService.find(:all, :order => "#{sort_by} ASC, name ASC")

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @services }
      format.json {
        @services = Service.find(:all)
          @json_export = ""
          @json_export << "{"
          @json_export <<   '"total": "'<< "#{@services.size()}" <<'", '
          @json_export <<   '"page": "1", '
          @json_export <<   '"records": "-1", '
          ActiveRecord::Base.include_root_in_json = false
          @json_export <<   '"services":'
          @json_export <<       @services.to_json(:only => [:id, :name, :dns_name, :typ, :group, :description], :methods => :systems_running_service)
          @json_export <<   ','
          @json_export <<   '"userdata":{'
            @json_export <<     '"systems":'
            @json_export <<         System.find(:all).to_json()
          @json_export <<   '}' #end userdata
          ActiveRecord::Base.include_root_in_json = true
          @json_export << "}" #end @json_export
         render :text => @json_export
      }
    end
  end



  # GET /services/1
  # GET /services/1.xml
  def show
    @service = CollectdService.find(params[:id], :include => :running_services)
    @systems = System.find(:all)

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @service }
      format.json  {
          @json_export = ""
          @json_export << "{"
          @json_export <<   '"service":'
          ActiveRecord::Base.include_root_in_json = false
          @json_export <<  @service.to_json(:except => [ :created_at, :updated_at ], :methods => [ :systems_running_service, :type ])
          ActiveRecord::Base.include_root_in_json = true
          @json_export << "}" #end @json_export
          render :text => @json_export
      }
    end
  end

  def edit
    @service = CollectdService.find(params[:id], :include => :running_services)
    @systems = System.find(:all)

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @service }
      format.json  {
          @json_export = ""
          @json_export << "{"
          @json_export <<   '"service":'
          ActiveRecord::Base.include_root_in_json = false
          @json_export <<  @service.to_json(:except => [ :created_at, :updated_at ], :methods => [ :systems_running_service, :type ])
          ActiveRecord::Base.include_root_in_json = true
          @json_export << "}" #end @json_export
          render :text => @json_export
      }
    end
  end



  # POST /services
  # POST /services.xml
  def create
    @service = CollectdService.new

    # HACK! DO NOT TOUCH; NEED TO REFACTOR WHOLE CONTROLLER!
    @service.last_change_user_id = @current_user.id
    # /HACK!

    respond_to do |format|
      if @service.update_attributes(params[:service])
        @json_export = ""
          @json_export << "{"
          @json_export <<   '"service":'
          ActiveRecord::Base.include_root_in_json = false
          @json_export <<       @service.to_json(:except => [ :created_at, :updated_at ], :methods => [ :systems_running_service, :type ] )
          ActiveRecord::Base.include_root_in_json = true
          @json_export << "}" #end @json_export
        format.json {render :text => @json_export}
      else
        format.json {render :text => 'false'}
      end
    end
  end

  # PUT /services/1
  # PUT /services/1.xml
  def update
    @service = CollectdService.find(params[:id])

    # HACK! DO NOT TOUCH; NEED TO REFACTOR WHOLE CONTROLLER!
    @service.last_change_user_id = @current_user.id
    # /HACK!

    if params[:create_running_services]
      @create_running_services = params[:create_running_services]
      for system_id in @create_running_services do
          @new_running_service = RunningService.new
          @new_running_service[:service_id] = params[:id]
          @new_running_service[:system_id] = system_id
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

    respond_to do |format|
      if params[:service]
        if @service.update_attributes(params[:service])
          format.html { redirect_to :action => "edit" }
#          flash[:notice] = "The service has been saved!"
          format.json  {
            @json_export = ""
            @json_export << "{"
            @json_export <<   '"service":'
            ActiveRecord::Base.include_root_in_json = false
            @json_export <<       @service.to_json(:except => [ :created_at, :updated_at ], :methods => :systems_running_service[ :systems_running_service, :type ])
            ActiveRecord::Base.include_root_in_json = true
            @json_export << "}"
            render :text => @json_export
          }
        else
          format.html { redirect_to :action => "edit" }
#          flash[:notice] = "Saving the service has been failed"
          format.json {render :text => 'false'}
        end
      end
    end
  end


end