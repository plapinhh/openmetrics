class RenameMetricIdsToMetricIdentifiersForThresholds < ActiveRecord::Migration
  def self.up
    rename_column :thresholds, :metric_ids, :metric_identifiers
  end

  def self.down
    rename_column :thresholds, :metric_identifiers, :metric_ids
  end
end
