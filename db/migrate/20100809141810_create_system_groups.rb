class CreateSystemGroups < ActiveRecord::Migration
  def self.up
    create_table :system_groups do |t|
      t.string :name

      t.timestamps
    end
  end

  def self.down
    drop_table :system_groups
  end
end
