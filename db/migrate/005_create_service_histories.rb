class CreateServiceHistories < ActiveRecord::Migration
  def self.up
    create_table :service_histories do |t|
      t.string :name
      t.string :typ
      t.string :group
      t.string :description
      t.integer :service_id
      t.timestamp :running_from
      t.timestamp :running_to

      t.timestamps
    end
  end

  def self.down
    drop_table :service_histories
  end
end
