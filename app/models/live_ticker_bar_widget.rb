class LiveTickerBarWidget < Widget

	  # store ui preferences as serialized json
	  # http://stackoverflow.com/questions/2959661/rails-serializing-objects-in-a-database
	  serialize :preferences


	  # Allow Children To Use Their Parent’s Routes
	  # http://code.alexreisner.com/articles/single-table-inheritance-in-rails.html
	  def self.model_name
	    name = "live_ticker_bar_widget"
	    name.instance_eval do
	      def plural;   pluralize;   end
	      def singular; singularize; end
	    end
	    return name
	  end

  def get_series(start_date, end_date, system, resolution = nil)
    series = {}
    system_id = system.id.to_s
    metrics = ActiveSupport::JSON.decode(self.preferences['metrics']) if self.preferences['metrics']
    metric_value_kind = 'average'

    metrics.each {|metric|
      metric_name = metric['metric']
      data = {}
      data[metric_name] = system.collectd_data(start_date, end_date, metric, metric_value_kind, resolution)
#      data[metric_name] = system.collectd_data(start_date, end_date, metric, metric_value_kind)
      series = series.merge(data)
    }
    return series
  end

  def get_last_values(start_date, end_date, system)
    series = {}
    system_id = system.id.to_s
    metrics = ActiveSupport::JSON.decode(self.preferences['metrics']) if self.preferences['metrics']
    metric_value_kind = 'average'

    metrics.each {|metric|
      data = system.collectd_last_value(start_date, end_date, metric, metric_value_kind)
      series = series.merge(data)
    }
    return series
  end
end
