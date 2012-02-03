class CreateCollectdPlugins < ActiveRecord::Migration
  def self.up
    create_table :collectd_plugins do |t|
      t.string :name
      t.text :configuration
      t.timestamps
    end

  end

  def self.down
    drop_table :collectd_plugins
  end
end
