class CreateThresholds < ActiveRecord::Migration
  def self.up
    create_table :thresholds do |t|
      t.string :metric_ids
      t.string :metric_filter
      t.boolean :metric_all
      t.string :system_ids
      t.string :system_filter
      t.boolean :system_all
      t.integer :failure_max
      t.integer :failure_min
      t.integer :warning_max
      t.integer :warning_min
      t.boolean :invert_values
      t.boolean :percentage
      t.boolean :persist

      t.timestamps
    end
  end

  def self.down
    drop_table :thresholds
  end
end
