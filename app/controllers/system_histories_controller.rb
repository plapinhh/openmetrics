class SystemHistoriesController < ApplicationController
  # GET /system_histories
  # GET /system_histories.xml
  def index
    @system_histories = SystemHistory.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @system_histories }
    end
  end

  # GET /system_histories/1
  # GET /system_histories/1.xml
  def show
    @system_history = SystemHistory.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @system_history }
    end
  end

  # GET /system_histories/new
  # GET /system_histories/new.xml
  def new
    @system_history = SystemHistory.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @system_history }
    end
  end

  # GET /system_histories/1/edit
  def edit
    @system_history = SystemHistory.find(params[:id])
  end

  # POST /system_histories
  # POST /system_histories.xml
  def create
    @system_history = SystemHistory.new(params[:system_history])

    respond_to do |format|
      if @system_history.save
        flash[:notice] = 'SystemHistory was successfully created.'
        format.html { redirect_to(@system_history) }
        format.xml  { render :xml => @system_history, :status => :created, :location => @system_history }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @system_history.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /system_histories/1
  # PUT /system_histories/1.xml
  def update
    @system_history = SystemHistory.find(params[:id])

    respond_to do |format|
      if @system_history.update_attributes(params[:system_history])
        flash[:notice] = 'SystemHistory was successfully updated.'
        format.html { redirect_to(@system_history) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @system_history.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /system_histories/1
  # DELETE /system_histories/1.xml
  def destroy
    @system_history = SystemHistory.find(params[:id])
    @system_history.destroy

    respond_to do |format|
      format.html { redirect_to(system_histories_url) }
      format.xml  { head :ok }
    end
  end
end
