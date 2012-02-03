class SystemGroupsController < ApplicationController
  layout "application"

  # GET /system_groups
  # GET /system_groups.xml
  def index
    @system_groups = SystemGroup.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @system_groups }
    end
  end

  # IN USE for MuninImageWidget forms
  def list_only
   sort_by = params[:sort_by]
    if sort_by == nil
      sort_by = "name"
    end
    @system_groups = SystemGroup.find(:all, :include => { :system_group_maps => :system }, :order => "#{sort_by} ASC, name ASC")
    respond_to do |format|
      format.html  { render :text => 'something wrong' }
      format.json  {
          @json_export = ""
          @json_export << "{"
          @json_export <<   '"system_groups":'
          ActiveRecord::Base.include_root_in_json = false
          @json_export <<       @system_groups.to_json(:include => { :system_group_maps => {:include => :system} })
          ActiveRecord::Base.include_root_in_json = true
          @json_export << "}" #end @json_export
          render :text => @json_export
      }
    end
  end

  # GET /system_groups/1
  # GET /system_groups/1.xml
  def show
    @system_group = SystemGroup.find(params[:id], :include => :system_group_maps)
    @systems = System.find(:all)

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @system_group }
    end
  end

  # GET /system_groups/new
  # GET /system_groups/new.xml
  def new
    @system_group = SystemGroup.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @system_group }
    end
  end

  # GET /system_groups/1/edit
  def edit
    @system_group = SystemGroup.find(params[:id], :include => { :system_group_maps =>  :system  } )
    @systems = System.find(:all)
  end

  # POST /system_groups
  # POST /system_groups.xml
  def create
    @system_group = SystemGroup.new(params[:system_group])

    respond_to do |format|
      if @system_group.save
        format.html { redirect_to(@system_group, :notice => 'SystemGroup was successfully created.') }
        format.xml  { render :xml => @system_group, :status => :created, :location => @system_group }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @system_group.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /system_groups/1
  # PUT /system_groups/1.xml
  def update
    @system_group = SystemGroup.find(params[:id])

    if params[:add_system_group_maps]
      @add_system_group_maps = params[:add_system_group_maps]
      for system_id in @add_system_group_maps do
          @add_system_group_map = SystemGroupMap.new
          @add_system_group_map[:system_group_id] = params[:id]
          @add_system_group_map[:system_id] = system_id
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

    respond_to do |format|
      if @system_group.update_attributes(params[:system_group])
        format.html { redirect_to(@system_group, :notice => 'SystemGroup was successfully updated.') }
        format.xml  { head :ok }
        format.json { render :text => 'true' }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @system_group.errors, :status => :unprocessable_entity }
        format.json { render :text => 'false' }
      end
    end
  end

  # DELETE /system_groups/1
  # DELETE /system_groups/1.xml
  def destroy
    @system_group = SystemGroup.find(params[:id])
    @system_group.destroy

    respond_to do |format|
      format.html { redirect_to(system_groups_url) }
      format.xml  { head :ok }
    end
  end
end
