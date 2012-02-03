class RenameWorkspacesToDashboards < ActiveRecord::Migration
  def self.up
    rename_table :workspaces, :dashboards
  end

  def self.down
  end
end
