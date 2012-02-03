class CreateRunningCollectdPlugins < ActiveRecord::Migration
  def self.up
    create_table :running_collectd_plugins do |t|
      t.integer :collectd_plugins_id
      t.integer :service_id
      t.timestamps
    end
  end

  def self.down
    drop_table :running_collectd_plugins
  end
end
