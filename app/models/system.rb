require 'graphviz' #used for relationsgraph

class System < ActiveRecord::Base

  has_many :running_services, :dependent => :destroy
  has_many :system_variables
  has_many :system_group_maps, :dependent => :destroy
  has_many :alerts
  has_and_belongs_to_many :metrics

  before_save 'sanitize_object self'
  before_save :fix_name 

  # History before_filter set
  def before_update
    # note: 'self' has already changed here! We need the DB Version again!
    SystemHistory.new.take_snapshot(System.find self.id)
  end

  def before_destroy
    SystemHistory.new.take_snapshot(System.find self.id)
  end
  # /History before_filter set
  
  # make sure system has a name, if not set to "unnamed"
  def fix_name
    if self.name.nil? or self.name.blank?
      write_attribute(:name, "unnamed")
    end
  end

  # get latest 100 alerts
  def recent_alerts
    self.alerts.find(:all, :order => 'created_at DESC', :limit => 100)
  end

  # iterate over systems running_services and checks whether there is a
  # service of type <arg> or not.
  #
  # returns true or false
  def has_service_of_type?(service_type)
    service_found = false
    rss = self.running_services.find(:all, :include => :service )
    rss.each do |rs|
      # rs.service.type gives deprecation warning
      if rs.service.class.name == "#{service_type}"
        service_found = true
      end
    end
    if service_found == true
      return true
    else
      return false
    end
  end

  # deprecated, use has_service_of_type instead
  def has_service?(service_id)
    running_services_with_id = self.running_services.find(:all, :conditions => {:service_id => service_id})
    if running_services_with_id.empty?
      return false
    else
      return true
    end
  end

  def get_state_at(timestamp)
    result = nil
    @history = SystemHistory.find(:all, :conditions => {:system_id => self.id})
    @history.each do |e|
      if timestamp.between?(e.running_from, e.running_to)
        # result found
        result = e if e.is_a? SystemHistory
      end
    end
    if result != nil 
      return result
    end
    return self
  end
  
  def get_running_services_at(timestamp)
    @rshistory = RunningServiceHistory.find(:all, :conditions => {:system_id => self.id})
    @result = []
    @rshistory.each do |e|
      if timestamp.between?(e.running_from, e.running_to)
        #result found
        @result << e;
      end
    end
    
    # we also need the ones that might be still running!
    @buffer = []
    @running_services = RunningService.find(:all, :conditions => {:system_id => self.id})
    @running_services.each do |e|
      if timestamp.between?(e.created_at,Time.now)
        # was created before timestamp and is still running
        # it might be there is already an old one in there!
        @ok = true
        
        @result.each do |r|
          if r.running_service_id == e.id
            @ok = false
          end
        end
        
        if @ok==true
          @buffer << e;
        end
        
      end
    end
    @result = @result.concat(@buffer)
    return @result
    
  end
  
  def get_services_state_at(timestamp)
    @previous_running_services = self.get_running_services_at(timestamp)
    @previous_services= []
    
    @previous_running_services.each do |e|
      @history = ServiceHistory.find(:all, :conditions => { :service_id => e.service_id})
      
      @history.each do |h|
        if timestamp.between?(h.running_from,h.running_to)
          # service has changed since timestamp
          @previous_services << h
        end
      end # @history.each
      
      @current = Service.find(e.service_id)
      if timestamp.between?(@current.updated_at, Time.now)
        # service has not changed since timestamp
        @previous_services << @current
      end
    end # @previous_running_services.each
    
    @previous_services.uniq! # there might be duplicates
    return @previous_services
    
  end # get_services_state_at(timestamp)

  # FIXME if socket holds recent data, e.g. because host (or collectd on that box
  #       died there should be a fallback to get metrics from actual rrd files
  def collectd_scan
#    return data_provider.get_all_metrics(self.fqdn)
    return data_provider.get_all_metrics_from_socket(self.fqdn)
  end
    
  def data_provider
    unless @data_provider
      require File.expand_path("../../../lib/data_providers/collectd/collectd", __FILE__)
      klass = DataProvider.from_shortname("collectd")
      @data_provider = klass.new()
    end
    @data_provider
  end

  def collectd_data(start_date,end_date, metric, metric_value_kind, resolution = nil)
    data = []
    data = data_provider.get_data(start_date, end_date, metric, metric_value_kind, self.fqdn, resolution)
    data = data.map do |x|
        # checking for nil values
        if (x[1].class == Float or x[1].class == Integer) and !x[1].nan?
          # second to millisecond and 2 hours time difference
#          [(x[0]+3600)*1000,x[1]]
#          [(x[0]),x[1]]
          [(x[0])*1000,x[1]]
        else
#          [(x[0]+3600)*1000,nil]
#          [(x[0]),nil]
          [(x[0])*1000,nil]
        end
    end
    data
  end

  def collectd_last_value(start_date,end_date, metric, metric_value_kind)
    data_provider.get_last_value(start_date, end_date, metric, metric_value_kind, self.fqdn)
  end
  
  def generate_relationsgraph
    g = GraphViz.new( :G, :type => :digraph )

    # set global node options
    g.node[:color]    = "#ddaa66"
    g.node[:style]    = "filled"
    g.node[:shape]    = "box"
    g.node[:penwidth] = "1"
    g.node[:fontname] = "Trebuchet MS"
    g.node[:fontsize] = "8"
    g.node[:fillcolor]= "#ffeecc"
    g.node[:fontcolor]= "#775500"
    g.node[:margin]   = "0.0"

    # set global edge options
    g.edge[:color]    = "#999999"
    g.edge[:weight]   = "1"
    g.edge[:fontsize] = "6"
    g.edge[:fontcolor]= "#444444"
    g.edge[:fontname] = "Verdana"
    g.edge[:dir]      = "forward"
    g.edge[:arrowsize]= "0.5"

    
    # Create two nodes
    hello = g.add_node( "Hello" )
    world = g.add_node( "World" )
    
    # Create an edge between the two nodes
    g.add_edge( hello, world )

    # Generate output image
    #g.output( :png => "/tmp/hello_world.png" )
    g.output(:svg => String)
  end
  
end # class
