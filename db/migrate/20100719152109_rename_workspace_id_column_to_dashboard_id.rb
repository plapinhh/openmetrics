class RenameWorkspaceIdColumnToDashboardId < ActiveRecord::Migration
  def self.up
    rename_column :widgets, :workspace_id, :dashboard_id
  end

  def self.down
  end
end
