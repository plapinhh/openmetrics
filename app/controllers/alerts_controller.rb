class AlertsController < ApplicationController
  # GET /alerts
  # GET /alerts.xml
  def index
#    @alerts = Alert.find :all, :include => :system, :order => 'created_at DESC'
     @alerts = Alert.paginate :page => params[:page], :per_page => 30, :order => "alerts.created_at DESC"

    add_breadcrumb('Alerts overview')

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @alerts }
    end
  end

  # GET /alerts/1
  # GET /alerts/1.xml
  def show
    @alert = Alert.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @alert }
    end
  end

  # currently used for alert_widget
  def recent
    start_date = Time.at(params[:start_date].to_i) - Time.zone.now.gmtoff
    # sort asc as alert_widget prepends alerts to top of output
    @alerts = Alert.find :all, :include => :system, :conditions => ["created_at >= ?", start_date], :order => 'created_at ASC'
    respond_to do |format|
      format.json do
        render :text => @alerts.to_json(:methods => :created_at_js, :include => :system)
      end
    end
  end

  # GET /alerts/new
  # GET /alerts/new.xml
  def new
    @alert = Alert.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @alert }
    end
  end

  # GET /alerts/1/edit
  def edit
    @alert = Alert.find(params[:id])
  end

  # POST /alerts
  # POST /alerts.xml
  def create
    @alert = Alert.new(params[:alert])

    respond_to do |format|
      if @alert.save
        format.html { redirect_to(@alert, :notice => 'Alert was successfully created.') }
        format.xml  { render :xml => @alert, :status => :created, :location => @alert }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @alert.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /alerts/1
  # PUT /alerts/1.xml
  def update
    @alert = Alert.find(params[:id])

    respond_to do |format|
      if @alert.update_attributes(params[:alert])
        format.html { redirect_to(@alert, :notice => 'Alert was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @alert.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /alerts/1
  # DELETE /alerts/1.xml
  def destroy
    @alert = Alert.find(params[:id])
    @alert.destroy

    respond_to do |format|
      format.html { redirect_to(alerts_url) }
      format.xml  { head :ok }
    end
  end
end
