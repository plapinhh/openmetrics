require 'socket'
class MonitoringWorker < BackgrounDRb::MetaWorker
  set_worker_name :monitoring_worker
  def create(args = nil)
    # this method is called, when worker is loaded for the first time
    #set_no_auto_load true #do not autoload on bdrb start
    logger.info "MonitoringWorker monitoring_worker started"

    # check all metric thresholds within 10 seconds interval
    loop.do {
      t1 = Time.now
      systems = []
      System.find(:all).each do |s|
        systems << s if s.has_service_of_type?("CollectdService")
      end
      systems.each do |system|
        check_metric_thresholds(system)
      end
      t2 = Time.now
      logger.info "MonitoringWorker summary: all metric thresholds checked, took #{t2-t1}s"
    }
    
  end
  
  # apply metric thresholds to collectd socket output of given system
  # warns & errors are creating an alert object
  # returns OK, ERROR, WARN or UNKNOWN
  def check_metric_thresholds(system)
    t1 = Time.now
    #logger.debug "MonitoringWorker start checking metric thresholds for system #{system.name} (#{system.fqdn})"
    socket_path = "/var/run/collectd-socket"    
    status = 'UNKNOWN' # initially set final status
    thresholds_status = [] # this will contain each thresholds status
    # fetch systems with running_service CollecdServer
    thresholds = Threshold.find :all  
    thresholds_to_apply = []
    thresholds.each { |t|
    	thresholds_to_apply << t if t.system_filter_ids.include?("#{system.id}")
    }
    
    # fetch metric value from socket and apply threshold
    thresholds_to_apply.each do |threshold|
      # TODO currently only the first metric_identifier is checked
      #puts threshold.inspect
      group, plugin, ds = threshold.metric_identifiers.first.split("/")
      socket = UNIXSocket.new(socket_path)
      socket.puts("GETVAL \"#{system.fqdn}/#{group}/#{plugin}\"") # double quotes for identifiers with whitspace
      first_line = socket.gets
      num_datasources = first_line.split(" ").first.to_i

      num_datasources.times do
        line = socket.gets
        s_ds = line.split("=")[0].to_s
        s_val = line.split("=")[1].to_f
#        puts "#{system.fqdn}/#{group}/#{plugin}/#{s_ds}: #{s_val}"
        # check value
        # TODO currently only the first metric_identifier is checked
        if threshold.metric_identifiers.first.include?(s_ds)
#          puts "#{system.fqdn}/#{group}/#{plugin}/#{s_ds}: applying threshold #{threshold.warning_min.to_f} to #{s_val}"
          if ( s_val < threshold.warning_min.to_f )
            thresholds_status << ["OK","#{threshold.metric_identifiers.first}","#{s_val}"] 
          elsif ( s_val >= threshold.failure_min.to_f )
            thresholds_status << ["ERROR","#{threshold.metric_identifiers.first}","#{s_val}"]
            a = Alert.new
            a.system_id = system.id
            a.severity = "ERROR"
            a.metric_identifier = "#{group}/#{plugin}/#{s_ds}"
            a.value = s_val
            a.warning_min = threshold.warning_min
            a.warning_max = threshold.warning_max
            a.failure_min = threshold.failure_min
            a.failure_max = threshold.failure_max
            a.save
          elsif ( s_val < threshold.failure_min.to_f )
            thresholds_status << ["WARN","#{threshold.metric_identifiers.first}","#{s_val}"]
            a = Alert.new
            a.system_id = system.id
            a.severity = "WARN"
            a.metric_identifier = "#{group}/#{plugin}/#{s_ds}"
            a.value = s_val
            a.warning_min = threshold.warning_min
            a.warning_max = threshold.warning_max
            a.failure_min = threshold.failure_min
            a.failure_max = threshold.failure_max
            a.save
          end          
        end
      end
      socket.close
     
    end

    # compute result from thresholds status
    # FIXME final status is still overwritten if thresholds_status looks like: [["ERROR", "cpu-0/cpu-user/value", "77.5"], ["WARN", "load/load/shortterm", "0.76"]]
#    puts thresholds_status.inspect
    thresholds_status.each do |ts|
      if ( ts.include?("OK"))
        status = 'OK'
      elsif ( ts.include?("WARN") )
        status = 'WARN'
      elsif ( ts.include?("ERROR") )
        status = 'ERROR'
      end
    end
    t2 = Time.now
    #logger.debug "MonitoringWorker metric thresholds for system #{system.name} (#{system.fqdn}) checked, took #{t2-t1}s, status #{status}"
    status
  end

end

