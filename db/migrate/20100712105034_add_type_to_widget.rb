class AddTypeToWidget < ActiveRecord::Migration
  def self.up
    add_column :widgets, :type, :string
  end

  def self.down
    remove_column :widgets, :type
  end
end
