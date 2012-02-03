class AddSeverityToAlerts < ActiveRecord::Migration
  def self.up
    add_column :alerts, :severity, :string
  end

  def self.down
    remove_column :alerts, :severity
  end
end
