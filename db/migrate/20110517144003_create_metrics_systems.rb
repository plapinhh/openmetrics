class CreateMetricsSystems < ActiveRecord::Migration
  def self.up
    create_table :metrics_systems do |t|
      t.references :system
      t.references :metric
    end
  end

  def self.down
    drop_table :metrics_systems
  end
end
