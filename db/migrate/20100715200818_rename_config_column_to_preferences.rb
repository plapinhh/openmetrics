class RenameConfigColumnToPreferences < ActiveRecord::Migration
  def self.up
      rename_column :widgets, :config, :preferences
  end

  def self.down
    # must be renamed to original value
    rename_column :widgets, :preferences, :config
  end
end
