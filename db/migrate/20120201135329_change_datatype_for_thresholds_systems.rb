class ChangeDatatypeForThresholdsSystems < ActiveRecord::Migration
  def self.up
    change_table :thresholds do |t|
      t.change :system_filter_ids, :text
    end
  end

  def self.down
    change_table :thresholds do |t|
      t.change :system_filter_ids, :string
    end
  end
end
