class CreateSystemHistories < ActiveRecord::Migration
  def self.up
    create_table :system_histories do |t|
      t.string :name
      t.string :ip
      t.string :site
      t.string :environment
      t.string :operating_system
      t.string :operating_system_flavour
      t.string :description
      t.string :responsible
      t.timestamp :running_from
      t.timestamp :running_to

      t.timestamps
    end
  end

  def self.down
    drop_table :system_histories
  end
end
