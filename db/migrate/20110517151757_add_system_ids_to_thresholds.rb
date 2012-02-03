class AddSystemIdsToThresholds < ActiveRecord::Migration
  def self.up
    add_column :thresholds, :system_filter_ids, :string
  end

  def self.down
    remove_column :thresholds, :system_filter_ids
  end
end
