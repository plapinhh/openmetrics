class AddZIndexToWidgets < ActiveRecord::Migration
  def self.up
    add_column :widgets, :zindex, :string
  end

  def self.down
    remove_column :widgets, :zindex
  end
end
