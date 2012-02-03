class CreateSystemGroupMaps < ActiveRecord::Migration
  def self.up
    create_table :system_group_maps do |t|
      t.integer :system_group_id
      t.integer :system_id
      t.timestamps
    end
  end

  def self.down
    drop_table :system_group_maps
  end
end
