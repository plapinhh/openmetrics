class ChangeDataTypeOfThresholds < ActiveRecord::Migration
  def self.up
    change_table :thresholds do |t|
      t.change :warning_min, :float
      t.change :warning_max, :float
      t.change :failure_min, :float
      t.change :failure_max, :float
    end
  end

  def self.down
  end
end
