class RenameCollectdPluginsIdColumnToCollectdPluginId < ActiveRecord::Migration
  def self.up
    rename_column :running_collectd_plugins, :collectd_plugins_id, :collectd_plugin_id
  end

  def self.down
  end
end
