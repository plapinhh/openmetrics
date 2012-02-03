class CreateRunningServiceHistories < ActiveRecord::Migration
  def self.up
    create_table :running_service_histories do |t|
      t.integer :system_id
      t.integer :service_id
      t.integer :running_service_id
      t.timestamp :running_from
      t.timestamp :running_to

      t.timestamps
    end
  end

  def self.down
    drop_table :running_service_histories
  end
end
