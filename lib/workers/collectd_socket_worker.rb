# collectd provides a unix socket for set/get metrics and related stuff like
# notifications
#
# you need to have collectd plugin up and running, see
# http://collectd.org/documentation/manpages/collectd-unixsock.5.shtml
# on how to achive this. also http://www.tutorialspoint.com/ruby/ruby_socket_programming.htm
# is useful

require 'socket' # unix magic 

# http://backgroundrb.rubyforge.org/files/README.html
class CollectdSocketWorker < BackgrounDRb::MetaWorker
  set_worker_name :collectd_socket_worker
  set_no_auto_load true #do not autoload on bdrb start

  # this method is called, when worker is loaded for the first time
  def create(args = nil)

  end

  # TODO
  def check_metric_freshness
    host = "wopr.parship.internal"
    plugin_instance = "load"
    type_instance = "load"
    identifier = "#{host}/#{plugin_instance}/#{type_instance}"

    file = "/var/run/collectd-unixsock"
    s = UNIXSocket.new(file)
    s.puts "GETVAL #{identifier}"
    while line = s.gets   # Read lines from the socket
      puts line.chop      # And print with platform line terminator
    end

    s.close
  end

  def get_value
    host = "wopr.parship.internal"
    plugin_instance = "load"
    type_instance = "load"
    identifier = "#{host}/#{plugin_instance}/#{type_instance}"

    file = "/var/run/collectd-unixsock"
    s = UNIXSocket.new(file)

    # GETVAL myhost/cpu-0/cpu-user <- | 1 Value found <- | value=1.260000e+00
    s.puts "GETVAL #{identifier}"

    # The response is a list of name-value-pairs, each pair on its own line
    # the number of lines is indicated by the status line, see above
    # Each name-value-pair is of the form name=value.
    # Counter-values are converted to a rate, e. g. bytes per second.
    # Undefined values are returned as NaN. this is a line "-1 No such value"
    while line = s.gets   # Read lines from the socket
      puts line.chop      # And print with platform line terminator
    end

    s.close               # Close the socket when done
  end

  def list
    file = "/var/run/collectd-unixsock"
    s = UNIXSocket.new(file)   
    
    #LISTVAL <- | 69 Values found <- | 1182204284 myhost/cpu-0/cpu-idle <- |
    #1182204284 myhost/cpu-0/cpu-nice <- | 1182204284 myhost/cpu-0/cpu-system <- |
    #1182204284 myhost/cpu-0/cpu-user ...
    s.puts "LISTVAL"

    # Returns a list of the values available in the value cache together with 
    # the time of the last update, so that querying applications can issue a 
    # GETVAL command for the values that have changed. Each return value consists 
    # of the update time as an epoch value and the identifier, separated by a 
    # space. The update time is the time of the last value, as provided by the 
    # collecting instance and may be very different from the time the server 
    # considers to be ``now''.    
    while line = s.gets   # Read lines from the socket
      puts line.chop      # And print with platform line terminator
    end

    s.close               # Close the socket when done
  end

  def put_value
    # TODO
  end

  def put_notfication
    # TODO
  end

end

