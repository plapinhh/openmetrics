class Threshold < ActiveRecord::Base
  serialize :metric_identifiers, Array
  serialize :system_filter_ids, Array

end
