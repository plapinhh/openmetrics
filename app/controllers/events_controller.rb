class EventsController < ApplicationController
  # GET /events
  # GET /events.xml
  def index
    @events = Event.find :all, :order => "created_at DESC"

    add_breadcrumb 'Events overview'

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @events }
      format.csv  {
          @csv_export = "";
          @sep = "|"
          # create headline
          @csv_export << "event.start_at#{@sep}event.end_at#{@sep}event.systems#{@sep}event.services#{@sep}event.systemGroups#{@sep}event.serviceGroups#{@sep}event.preferences\n"
          @events.each do |e|
            @csv_export << "#{e.start_at}#{@sep}#{e.end_at}#{@sep}#{e.systems}#{@sep}#{e.services}#{@sep}#{e.systemGroups}#{@sep}#{e.serviceGroups}#{@sep}#{e.preferences}\n"
          end
          send_data(@csv_export,
                    :type => 'text/csv; charset=utf-8; header=present',
                    :filename => "eventslist.csv")

        } # format csv
    end
  end

  # GET /events/1
  # GET /events/1.xml
  def show
#    @event = Event.find(params[:id])

#    respond_to do |format|
      redirect_to :action => 'edit'
#      format.html # show.html.erb
#      format.xml  { render :xml => @event }
#    end
  end

  # GET /events/new
  # GET /events/new.xml
  def new
    @event = Event.new
    @event.start_at = Time.zone.now
    @event.end_at = Time.zone.now + 1.hours

    respond_to do |format|
      format.html { render 'form' }
      format.xml# { render :xml => @event }
    end
  end

  # GET /events/1/edit
  def edit
    @event = Event.find(params[:id])
    add_breadcrumb @event.name, 'event'

    respond_to do |format|
      format.html { render 'form' }
      format.xml# { render :xml => @event }
    end
  end

  # POST /events
  # POST /events.xml
  def create
    @event = Event.new(params[:event])
    @event.preferences = ActiveSupport::JSON.encode(params[:preferences]) if params[:preferences]

    if params[:create_affected_systems]
      create_affected_systems = params[:create_affected_systems]
      @event.systems = (@event.systems && ActiveSupport::JSON.decode(@event.systems)) || []
      @event.systems = @event.systems + create_affected_systems
      @event.systems.uniq
      @event.systems = ActiveSupport::JSON.encode(@event.systems)
    end

    respond_to do |format|
      if @event.save
#        format.html { redirect_to(@event, :notice => 'Event was successfully created.') }
#        format.xml  { render :xml => @event, :status => :created, :location => @event }
        format.json  { render :json => @event }
      else
        format.json { render :text => 'false' }
#        format.html { render :action => "new" }
#        format.xml  { render :xml => @event.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /events/1
  # PUT /events/1.xml
  def update
    @event = Event.find(params[:id])
    @event.preferences = ActiveSupport::JSON.encode(params[:preferences]) if params[:preferences]

    if params[:create_affected_systems]
      create_affected_systems = params[:create_affected_systems]
      @event.systems = (@event.systems && ActiveSupport::JSON.decode(@event.systems)) || []
      @event.systems = @event.systems + create_affected_systems
      @event.systems.uniq
      @event.systems = ActiveSupport::JSON.encode(@event.systems)
    end

    if params[:destroy_affected_systems]
      destroy_affected_systems = params[:destroy_affected_systems]
      if @event.systems
        @event.systems = ActiveSupport::JSON.decode(@event.systems)
        @event.systems = @event.systems - destroy_affected_systems
        @event.systems.uniq
        @event.systems = ActiveSupport::JSON.encode(@event.systems)
      end
    end

    respond_to do |format|
      if @event.update_attributes(params[:event])
#        format.html { redirect_to(@event, :notice => 'Event was successfully updated.') }
#        format.xml  { head :ok }
        format.json  { render :json => @event }
      else
         format.json { render :text => 'false' }
#        format.html { render :action => "edit" }
#        format.xml  { render :xml => @event.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /events/1
  # DELETE /events/1.xml
  def destroy
    @event = Event.find(params[:id])
    @event.destroy

    respond_to do |format|
      format.html { redirect_to(events_url) }
      format.xml  { head :ok }
      format.json  { render :text => 'true' }
    end
  end
end
