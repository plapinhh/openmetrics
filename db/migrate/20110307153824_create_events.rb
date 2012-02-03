class CreateEvents < ActiveRecord::Migration
  def self.up
    create_table :events do |t|
      t.timestamp :start_at
      t.timestamp :end_at
      t.text :systems
      t.text :services
      t.text :systemGroups
      t.text :serviceGroups
      t.text :preferences

      t.timestamps
    end
  end

  def self.down
    drop_table :events
  end
end
