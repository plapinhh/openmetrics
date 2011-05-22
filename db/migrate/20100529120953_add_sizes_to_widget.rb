class AddSizesToWidget < ActiveRecord::Migration
  def self.up
    add_column :widgets, :sizex, :integer
    add_column :widgets, :sizey, :integer
  end

  def self.down
    remove_column :widgets, :sizey
    remove_column :widgets, :sizex
  end
end
