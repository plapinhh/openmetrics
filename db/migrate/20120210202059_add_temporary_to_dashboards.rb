class AddTemporaryToDashboards < ActiveRecord::Migration

  def self.up
    add_column :dashboards, :temporary, :boolean, :default => false
  end

  def self.down
    delete_column :dashboards, :temporary, :boolean
  end

end
