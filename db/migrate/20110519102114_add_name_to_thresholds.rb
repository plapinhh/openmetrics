class AddNameToThresholds < ActiveRecord::Migration
  def self.up
    add_column :thresholds, :name, :string
  end

  def self.down
    delete_column :thresholds, :name, :string
  end
end
