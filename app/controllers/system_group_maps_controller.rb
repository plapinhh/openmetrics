class SystemGroupMapsController < ApplicationController
  # GET /system_group_maps
  # GET /system_group_maps.xml
  def index
    @system_group_maps = SystemGroupMap.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @system_group_maps }
    end
  end

  # GET /system_group_maps/1
  # GET /system_group_maps/1.xml
  def show
    @system_group_map = SystemGroupMap.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @system_group_map }
    end
  end

  # GET /system_group_maps/new
  # GET /system_group_maps/new.xml
  def new
    @system_group_map = SystemGroupMap.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @system_group_map }
    end
  end

  # GET /system_group_maps/1/edit
  def edit
    @system_group_map = SystemGroupMap.find(params[:id])
  end

  # POST /system_group_maps
  # POST /system_group_maps.xml
  def create
    @system_group_map = SystemGroupMap.new(params[:system_group_map])

    respond_to do |format|
      if @system_group_map.save
        format.html { redirect_to(@system_group_map, :notice => 'SystemGroupMap was successfully created.') }
        format.xml  { render :xml => @system_group_map, :status => :created, :location => @system_group_map }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @system_group_map.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /system_group_maps/1
  # PUT /system_group_maps/1.xml
  def update
    @system_group_map = SystemGroupMap.find(params[:id])

    respond_to do |format|
      if @system_group_map.update_attributes(params[:system_group_map])
        format.html { redirect_to(@system_group_map, :notice => 'SystemGroupMap was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @system_group_map.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /system_group_maps/1
  # DELETE /system_group_maps/1.xml
  def destroy
    @system_group_map = SystemGroupMap.find(params[:id])
    @system_group_map.destroy

    respond_to do |format|
      format.html { redirect_to(system_group_maps_url) }
      format.xml  { head :ok }
    end
  end
end
