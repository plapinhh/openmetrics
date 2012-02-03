class RunningServiceHistoriesController < ApplicationController
  # GET /running_service_histories
  # GET /running_service_histories.xml
  def index
    @running_service_histories = RunningServiceHistory.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @running_service_histories }
    end
  end

  # GET /running_service_histories/1
  # GET /running_service_histories/1.xml
  def show
    @running_service_history = RunningServiceHistory.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @running_service_history }
    end
  end

  # GET /running_service_histories/new
  # GET /running_service_histories/new.xml
  def new
    @running_service_history = RunningServiceHistory.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @running_service_history }
    end
  end

  # GET /running_service_histories/1/edit
  def edit
    @running_service_history = RunningServiceHistory.find(params[:id])
  end

  # POST /running_service_histories
  # POST /running_service_histories.xml
  def create
    @running_service_history = RunningServiceHistory.new(params[:running_service_history])

    respond_to do |format|
      if @running_service_history.save
        flash[:notice] = 'RunningServiceHistory was successfully created.'
        format.html { redirect_to(@running_service_history) }
        format.xml  { render :xml => @running_service_history, :status => :created, :location => @running_service_history }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @running_service_history.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /running_service_histories/1
  # PUT /running_service_histories/1.xml
  def update
    @running_service_history = RunningServiceHistory.find(params[:id])

    respond_to do |format|
      if @running_service_history.update_attributes(params[:running_service_history])
        flash[:notice] = 'RunningServiceHistory was successfully updated.'
        format.html { redirect_to(@running_service_history) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @running_service_history.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /running_service_histories/1
  # DELETE /running_service_histories/1.xml
  def destroy
    @running_service_history = RunningServiceHistory.find(params[:id])
    @running_service_history.destroy

    respond_to do |format|
      format.html { redirect_to(running_service_histories_url) }
      format.xml  { head :ok }
    end
  end
end
