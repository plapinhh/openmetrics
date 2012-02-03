class RemoveMetricAllFromThresholds < ActiveRecord::Migration
  def self.up
    remove_column :thresholds, :metric_all
  end

  def self.down
    add_column :thresholds, :metric_all
  end
end
