class RemoveSiteFromSystem < ActiveRecord::Migration
  def self.up
    remove_column :systems, :site
  end

  def self.down
    add_column :systems, :site, :string
  end
end
