class CreateSystemVariables < ActiveRecord::Migration
  def self.up
    create_table :system_variables do |t|
      t.string :name
      t.string :value
      t.integer :system_id

      t.timestamps
    end
  end

  def self.down
    drop_table :system_variables
  end
end
