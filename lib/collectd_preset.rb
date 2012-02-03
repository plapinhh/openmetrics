class CollectdPreset
  
  private_class_method :new

#    METRIC_PRESET = {}
#    METRIC_PRESET["CPU"] = {}
#    METRIC_PRESET["CPU"]['preset_name']="CPU"
#    METRIC_PRESET["CPU"]['unit']="jiffies"
#    METRIC_PRESET["CPU"]['stacked']=true
#    METRIC_PRESET["CPU"]['filter']="^cpu"
#    METRIC_PRESET["MEMORY"] = {}
#    METRIC_PRESET["MEMORY"]['preset_name']="MEMORY"
#    METRIC_PRESET["MEMORY"]['unit']="bytes"
#    METRIC_PRESET["MEMORY"]['stacked']=true
#    METRIC_PRESET["MEMORY"]['filter']="^memory"
#    METRIC_PRESET["LOAD"] = {}
#    METRIC_PRESET["LOAD"]['preset_name']="LOAD"
#    METRIC_PRESET["LOAD"]['unit']="value"
#    METRIC_PRESET["LOAD"]['stacked']=nil
#    METRIC_PRESET["LOAD"]['filter']="^load"
#    METRIC_PRESET["DF"] = {}
#    METRIC_PRESET["DF"]['preset_name']="Disk free"
#    METRIC_PRESET["DF"]['unit']="bytes"
#    METRIC_PRESET["DF"]['stacked']=nil
#    METRIC_PRESET["DF"]['filter']="^df.*free"
#    METRIC_PRESET["DU"] = {}
#    METRIC_PRESET["DU"]['preset_name']="Disk used"
#    METRIC_PRESET["DU"]['unit']="bytes"
#    METRIC_PRESET["DU"]['stacked']=nil
#    METRIC_PRESET["DU"]['filter']="^df.*used"
#    METRIC_PRESET["DISK-SDA"] = {}
#    METRIC_PRESET["DISK-SDA"]['preset_name']="DISK-SDA"
#    METRIC_PRESET["DISK-SDA"]['unit']="seconds"
#    METRIC_PRESET["DISK-SDA"]['stacked']=nil
#    METRIC_PRESET["DISK-SDA"]['filter']="^disk-sda"

  @@presets = {}
  @@load, @@cpu, @@interface = nil

  def initialize(name, filter, value, stacked)
    @name     = name
    @filter   = filter
    @unit = value
    @stacked = stacked
  end

  def self.create
    @@load = @@presets['load'] = new('load', "^load", "value", nil) unless @@load
    @@cpu = @@presets['cpu'] = new('cpu', "^cpu", "jiffies", nil) unless @@cpu
    @@interface = @@presets['interface'] = new('interface', "^interface", "bytes", nil) unless @@interface
    self
  end

  def self.get_all_presets
    @@presets
  end

  def self.get_preset_from_name(name)
    @@presets[name.downcase] || false
  end

  def self.get_series_for_preset(preset, start_date, end_date, system, metric_value_kind)
    preset.send(preset.get_name.downcase, start_date, end_date, system, metric_value_kind)
  end

  def get_name
    @name
  end

  def get_filter
    @filter
  end

  def get_unit
    @unit
  end

  def method_missing(name, *args, &blk)
    self.default(*args)
  end

  def filter_metrics (all_system_metrics)
    metrics = []
    all_system_metrics.each { |m|
      if (m['metric'].match(/#{@filter}/))
        metrics << m
      end
    }
    metrics
  end

  def load (start_date, end_date, system, metric_value_kind)
    all_system_metrics = system.collectd_scan
    stacked = false
    fill = false

    series = []
    system_id = system.id.to_s

    metrics = self.filter_metrics(all_system_metrics)
    metrics.each { |metric|
      line_color = "#22FF22" if ( metric['metric'] =~ /.*_shortterm$/ )
      line_color = "#00AA00" if ( metric['metric'] =~ /.*_midterm$/ )
      line_color = "#21460B" if ( metric['metric'] =~ /.*_longterm$/ )
      line_width = "0.7" if ( metric['metric'] =~ /.*_shortterm$/ )
      line_width = "0.7" if ( metric['metric'] =~ /.*_midterm$/ )
      line_width = "0.7" if ( metric['metric'] =~ /.*_longterm$/ )

      s = Hash.new
      s[:shadowSize] = 0
      s[:lines] = Hash.new
      s[:color] = line_color
      s[:label] = system.name + ": " + metric['metric']
      s[:stack] = stacked
      s[:lines][:lineWidth] = line_width
      s[:lines][:fill] = fill

      s[:data] = system.collectd_data(start_date, end_date, metric, metric_value_kind)
      series.push(s)
    }
    return series
  end
  
  def cpu (start_date, end_date, system, metric_value_kind)
    stacked = system.id
    fill = true
    metric_rrds = ["cpu-system", "cpu-user", "cpu-nice", "cpu-idle", "cpu-wait", "cpu-interrupt", "cpu-softirq", "cpu-steal"]
    metric_rrds.reverse!
    series = []
    all_system_metrics = system.collectd_scan

    metrics = self.filter_metrics(all_system_metrics)
    metric_rrds.each { |metric_rrd|
      line_color = "#22FF22" if ( metric_rrd =~ /^cpu-system$/ )
      line_color = "#0022FF" if ( metric_rrd =~ /^cpu-user$/ )
      line_color = "#FF0000" if ( metric_rrd =~ /^cpu-nice$/ )
      line_color = "#00AAAA" if ( metric_rrd =~ /^cpu-idle$/ )
      line_color = "#FF00FF" if ( metric_rrd =~ /^cpu-wait$/ )
      line_color = "#FFA500" if ( metric_rrd =~ /^cpu-interrupt$/ )
      line_color = "#FFA500" if ( metric_rrd =~ /^cpu-softirq$/ )
      line_color = "#0000CC" if ( metric_rrd =~ /^cpu-steal$/ )

      s = Hash.new
      s[:shadowSize] = 0
      s[:lines] = Hash.new

      matched_metrics = metrics.find_all { |m| m['metric_options']['metric_rrd'] == metric_rrd }

      s[:color] = line_color
      s[:label] = (system.name + ": " + metric_rrd)
      s[:stack] = stacked || false
      s[:lines][:lineWidth] = 0.7
      s[:lines][:fill] = fill || false

      data_arrays_to_reduce = []
      matched_metrics.each { |metric|
        data = system.collectd_data(start_date, end_date, metric, metric_value_kind)
        data_arrays_to_reduce.push(data)
      }
      reduced_array = data_arrays_to_reduce.transpose.map{ |array|
        timestamp = array[0][0]
        values = array.transpose[1]
        values_sum = nil
        values.each do | value |
          if value
            values_sum = 0 if values_sum.nil?
            values_sum = values_sum + value
          else
            values_sum = values_sum
          end
        end
        [timestamp, values_sum]
      }
      s[:data] = reduced_array
      series.push(s)
    }
    return series
  end

  def interface (start_date, end_date, system, metric_value_kind)
    stacked = system.id
    fill = true
    metric_rrds = ["if_octets-"]
    series = []
    all_system_metrics = system.collectd_scan

    metrics = self.filter_metrics(all_system_metrics)
    metrics.each {|metric|
      line_color = "#22FF22" if ( metric['metric'] =~ /.*if_octets-.*_rx$/ )
      line_color = "#21460B" if ( metric['metric'] =~ /.*if_octets-.*_tx$/ )

      s = Hash.new
      s[:shadowSize] = 0
      s[:lines] = Hash.new

      s[:label] = (system.name + ": " + metric['metric'])
      s[:stack] = false
      s[:lines][:lineWidth] = 0.7
      s[:lines][:fill] = false

      s[:data] = system.collectd_data(start_date, end_date, metric, metric_value_kind)
      series.push(s)
    }
    return series
  end
  

  def default (start_date, end_date, system, metric_value_kind)
    series = []
    system_id = system.id.to_s
    all_system_metrics = system.collectd_scan

    metrics = self.filter_metrics(all_system_metrics)

    metrics.each {|metric|
      s = Hash.new
      s[:shadowSize] = 0
      s[:lines] = Hash.new

      s[:label] = (system.name + ": " + metric['metric'])
      s[:stack] = false
      s[:lines][:lineWidth] = 0.7
      s[:lines][:fill] = false

      s[:data] = system.collectd_data(start_date, end_date, metric, metric_value_kind)
      series.push(s)
    }
    return series
  end


end
