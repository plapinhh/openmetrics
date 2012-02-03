require 'collectd_preset'
class CollectdImageWidget < Widget

#Allow Children To Use Their Parent’s Routes
#http://code.alexreisner.com/articles/single-table-inheritance-in-rails.html
  def self.model_name
    name = "collectd_image_widget"
    name.instance_eval do
      def plural;   pluralize;   end
      def singular; singularize; end
    end
    return name
  end

  def get_start_end_dates
    start_date = Time.now - 13.month
    start_date = Time.parse(self.preferences['start_date']) if self.preferences['start_date'] and Time.parse(self.preferences['start_date'])
    start_date = Time.now - 1.week if start_date < Time.now - 400.day

    end_date = Time.now
    end_date = Time.parse(self.preferences['end_date']).end_of_day if self.preferences['end_date'] and Time.parse(self.preferences['end_date'])
    end_date = Time.now if end_date > Time.now

    # TODO for dynamic daterange selection one should be able to choose whether to include 'today' or not by checkbox
    if (self.preferences['date_range'])
      range = self.preferences['date_range'].to_s.split("_")[0]
      end_date = Time.now.beginning_of_day
      case range
        when "today"
          end_date = start_date = Time.now
        when "lastday"
          start_date = Time.now - 1.day
          end_date = Time.now
        when "lastweek"
          start_date = Time.now - 1.week
          end_date = Time.now
        when "lastmonth"
          start_date = Time.now - 1.month
          end_date = Time.now
        when "last3months"
          start_date = Time.now - 3.month
          end_date = Time.now
        when "lastyear"
          start_date = Time.now - 1.year
          end_date = Time.now
      end
    end
    start_date = start_date.beginning_of_day

    return [start_date, end_date]
  end

  def get_metric_value_kind
      if (self.preferences['metric_value_kind'] && !self.preferences['metric_value_kind'].to_s.empty?)
        return self.preferences['metric_value_kind']
      else
        return "average"
      end
  end

  def get_events start_date, end_date, system_ids
    result = []
    # push event objects to the respond
    if self.preferences['show_events']
      # fist filtering of events: by start and end date
      events = Event.find(:all, :conditions => ["start_at >= ? and end_at <= ?", start_date, end_date])

      if events.size > 0
        events.each {|e|
          if e.systems
            # second filtering of events: by affected systems
            event_systems = ActiveSupport::JSON.decode(e.systems)
            intersection = event_systems & system_ids
            if !intersection.empty?
              # translate second to millisecond, pack prefs to json string, hard set for color (futural use as event preference could be nice)
              event = {:xaxis=> {:from=> e.start_at.to_i*1000, :to => e.end_at.to_i*1000}, :id => e.id, :prefs => ActiveSupport::JSON.decode(e.preferences), :color => "#000000"}
              result.push(event)
            end
          end
        }
      end
    end
    return result
  end

  def get_series (start_date, end_date, system_id)
    system = System.find(system_id.to_i)
    preset = self.get_preset
    if (preset)
      series = get_series_for_preset(start_date, end_date, system, preset)
    else
      series = get_series_for_metrics(start_date, end_date, system)
    end
    return series
  end

  def get_series_for_preset (start_date, end_date, system, preset)
    series = []
    metric_value_kind = self.get_metric_value_kind
    series = CollectdPreset.create.get_series_for_preset(preset, start_date, end_date, system, metric_value_kind)
    return series
  end

  def get_series_for_metrics (start_date, end_date, system)
    series = []
    system_id = system.id.to_s
    metrics = ActiveSupport::JSON.decode(self.preferences['metrics']) if self.preferences['metrics']
    metric_value_kind = self.get_metric_value_kind

    metrics.each {|metric|
      s = Hash.new
      s[:shadowSize] = 0
      s[:lines] = Hash.new

      m = metrics.find { |m| m['metric'] == metric['metric'] }
      metric_settings = m['metric_settings'] if m && m['metric_settings']

      s[:color] = metric_settings[system_id]['line_color'] if (metric_settings && metric_settings != nil && metric_settings[system_id]['line_color'] && metric_settings[system_id]['line_color'] =~ /^\#([a-fA-F0-9]{6}|[a-fA-F0-9]{3})$/)# || index
      s[:label] = (metric_settings && metric_settings != nil && metric_settings[system_id]['label']) || (system.name + ": " + metric['metric'])
      s[:stack] = (metric_settings && metric_settings != nil && metric_settings[system_id]['stack']) || false
      s[:lines][:lineWidth] = (metric_settings && metric_settings != nil && metric_settings[system_id]['line_width']) || 0.7
      s[:lines][:fill] = (metric_settings && metric_settings != nil && metric_settings[system_id]['fill']) || false

      s[:data] = system.collectd_data(start_date, end_date, metric, metric_value_kind)
#      puts s[:data]
      series.push(s)
    }
    return series
  end

  def get_preset
    if (self.preferences['metric_preset'] && !self.preferences['metric_preset'].to_s.empty?)
      preset = CollectdPreset.create.get_preset_from_name(self.preferences['metric_preset'])
      return preset
    else
      return false
    end
  end

end
