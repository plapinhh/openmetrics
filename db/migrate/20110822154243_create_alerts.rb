class CreateAlerts < ActiveRecord::Migration
  def self.up
    create_table :alerts do |t|
      t.integer :system_id
      t.string :metric_identifier
      t.float :value
      t.float :warning_min
      t.float :warning_max
      t.float :failure_min
      t.float :failure_max

      t.timestamps
    end
  end

  def self.down
    drop_table :alerts
  end
end
