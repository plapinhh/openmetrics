class CreateRunningServices < ActiveRecord::Migration
  def self.up
    create_table :running_services do |t|
      t.integer :system_id
      t.integer :service_id
      t.string :comment

      t.timestamps
    end
  end

  def self.down
    drop_table :running_services
  end
end
