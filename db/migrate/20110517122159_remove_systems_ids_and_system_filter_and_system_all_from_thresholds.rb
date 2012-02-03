class RemoveSystemsIdsAndSystemFilterAndSystemAllFromThresholds < ActiveRecord::Migration
  def self.up
    remove_column :thresholds, :system_ids, :system_all, :system_filter
  end

  def self.down
    add_column :thresholds, :thresholds, :system_ids, :system_all, :system_filter
  end
end
