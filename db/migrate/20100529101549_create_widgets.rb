class CreateWidgets < ActiveRecord::Migration
  def self.up
    create_table :widgets do |t|
      t.integer :workspace_id
      t.integer :top
      t.integer :left
      t.timestamps
    end
  end
  
  def self.down
    drop_table :widgets
  end
end
