namespace :openmetrics do

  #
  # rake openmetrics:metric_setup
  #

  desc "Fetches metrics from server over unix socket and puts them to the database"
  task(:metric_setup => :environment) do

    puts "\nMetric setup start..."

    puts "\nDeleting existing metrics..."
    Metric.destroy_all()
    puts "\n...done"

    socket_path = "/var/run/collectd-socket"

    # 1)
    socket = UNIXSocket.new(socket_path)
    socket.puts("LISTVAL")
    first_line = socket.gets
    num_results = first_line.split(" ").first.to_i

    puts "\nFound rrd files: " << num_results.to_s

    puts "\nStart creating metrics. It may take a while...\n"

    # 2)
    # TODO this isn't really effective as socket.gets will be called num_result times
    metric_list = []
    num_results.times do
      line = socket.gets.split(" ").second
      metric_list << line.strip
    end

    socket.close


    # 3)
    metric_list.each do |identifier|

      #puts identifier
      #puts last_update

      socket = UNIXSocket.new(socket_path)
      socket.puts("GETVAL #{identifier}")
      first_line = socket.gets

      num_datasources = first_line.split(" ").first.to_i

      hostname, group, plugin = identifier.split("/")
      system = System.find_by_fqdn(hostname)

      if !system
        puts "ERROR: couldn't find system for #{identifier}. Please create it and retry!"
      else
        puts "processing #{identifier} - system: #{system.name} (#{hostname})"
      end

      num_datasources.times do
        line = socket.gets
        ds = line.split("=")[0]

        metric = Metric.find_by_group_and_plugin_and_ds(group, plugin, ds)
        if !metric
          metric = Metric.new(
            :group => group,
            :plugin => plugin,
            :ds => ds)
          metric.save!
        end
        metric.systems << system
      end

      socket.close
    end

    puts "\nMetric setup complete!"
      
  end #task
end
