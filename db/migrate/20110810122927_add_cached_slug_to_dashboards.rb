class AddCachedSlugToDashboards < ActiveRecord::Migration
  def self.up
    add_column :dashboards, :cached_slug, :string
    add_index  :dashboards, :cached_slug, :unique => true
  end

  def self.down
    remove_column :dashboards, :cached_slug
  end
end
