class RunningServicesController < ApplicationController
  # GET /running_services
  # GET /running_services.xml
  def index
    @running_services = RunningService.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @running_services }
    end
  end

  # GET /running_services/1
  # GET /running_services/1.xml
  def show
    @running_service = RunningService.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @running_service }
    end
  end

  # GET /running_services/new
  # GET /running_services/new.xml
  def new
    @running_service = RunningService.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @running_service }
    end
  end

  # GET /running_services/1/edit
  def edit
    @running_service = RunningService.find(params[:id])
  end

  # POST /running_services
  # POST /running_services.xml
  def create
    @running_service = RunningService.new(params[:running_service])
   
    respond_to do |format|
      if @running_service.save
        flash[:notice] = 'RunningService was successfully created.'
        format.html  {
          #redirect_to(System.find(@running_service.system_id))  if params[:redirect_to] == "system"
          #redirect_to(Service.find(@running_service.service_id))  if params[:redirect_to] == "service"
          redirect_to :back
        }
        
        format.xml  { render :xml => @running_service, :status => :created, :location => @running_service }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @running_service.errors, :status => :unprocessable_entity }
      end
    end
    
    
    # @running_service = RunningService.new(params[:running_service])

    # respond_to do |format|
    # if @running_service.save
    # flash[:notice] = 'RunningService was successfully created.'
    # format.html { redirect_to(@running_service) }
    # format.xml  { render :xml => @running_service, :status => :created, :location => @running_service }
    # else
    # format.html { render :action => "new" }
    # format.xml  { render :xml => @running_service.errors, :status => :unprocessable_entity }
    # end
    # end
  end

  # PUT /running_services/1
  # PUT /running_services/1.xml
  def update
    @running_service = RunningService.find(params[:id])

    respond_to do |format|
      if @running_service.update_attributes(params[:running_service])
        flash[:notice] = 'RunningService was successfully updated.'
        format.html { redirect_to(@running_service) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @running_service.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /running_services/1
  # DELETE /running_services/1.xml
  def destroy
    @running_service = RunningService.find(params[:id])
    @system_id = @running_service.system_id
    @running_service.destroy

    respond_to do |format|
      format.html { redirect_to(System.find(@system_id)) }
      format.xml  { head :ok }
    end
  end
end
