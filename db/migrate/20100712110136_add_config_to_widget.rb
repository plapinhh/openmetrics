class AddConfigToWidget < ActiveRecord::Migration
  def self.up
    add_column :widgets, :config, :text
  end

  def self.down
    remove_column :widgets, :config
  end
end
