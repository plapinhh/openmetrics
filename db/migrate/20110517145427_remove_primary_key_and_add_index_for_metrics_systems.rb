class RemovePrimaryKeyAndAddIndexForMetricsSystems < ActiveRecord::Migration
  def self.up
    drop_table :metrics_systems
    create_table :metrics_systems, :id => false do |t|
      t.references :system
      t.references :metric
    end
    add_index :metrics_systems, [ :metric_id, :system_id ], :unique => true
  end

  def self.down
    drop_table :metrics_systems
    create_table :metrics_systems do |t|
      t.references :system
      t.references :metric
    end
  end
end
