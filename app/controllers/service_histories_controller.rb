class ServiceHistoriesController < ApplicationController
  # GET /service_histories
  # GET /service_histories.xml
  def index
    @service_histories = ServiceHistory.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @service_histories }
    end
  end

  # GET /service_histories/1
  # GET /service_histories/1.xml
  def show
    @service_history = ServiceHistory.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @service_history }
    end
  end

  # GET /service_histories/new
  # GET /service_histories/new.xml
  def new
    @service_history = ServiceHistory.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @service_history }
    end
  end

  # GET /service_histories/1/edit
  def edit
    @service_history = ServiceHistory.find(params[:id])
  end

  # POST /service_histories
  # POST /service_histories.xml
  def create
    @service_history = ServiceHistory.new(params[:service_history])

    respond_to do |format|
      if @service_history.save
        flash[:notice] = 'ServiceHistory was successfully created.'
        format.html { redirect_to(@service_history) }
        format.xml  { render :xml => @service_history, :status => :created, :location => @service_history }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @service_history.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /service_histories/1
  # PUT /service_histories/1.xml
  def update
    @service_history = ServiceHistory.find(params[:id])

    respond_to do |format|
      if @service_history.update_attributes(params[:service_history])
        flash[:notice] = 'ServiceHistory was successfully updated.'
        format.html { redirect_to(@service_history) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @service_history.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /service_histories/1
  # DELETE /service_histories/1.xml
  def destroy
    @service_history = ServiceHistory.find(params[:id])
    @service_history.destroy

    respond_to do |format|
      format.html { redirect_to(service_histories_url) }
      format.xml  { head :ok }
    end
  end
end
