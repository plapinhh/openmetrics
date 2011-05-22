class AddUriToWidget < ActiveRecord::Migration
  def self.up
    add_column :widgets, :uri, :string
  end

  def self.down
    remove_column :widgets, :uri
  end
end
