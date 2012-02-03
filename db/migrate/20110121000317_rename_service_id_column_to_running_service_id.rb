class RenameServiceIdColumnToRunningServiceId < ActiveRecord::Migration
  def self.up
    rename_column :running_collectd_plugins, :service_id, :running_service_id
  end

  def self.down
  end
end
