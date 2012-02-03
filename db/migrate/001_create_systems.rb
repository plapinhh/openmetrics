class CreateSystems < ActiveRecord::Migration
  def self.up
    create_table :systems do |t|
      t.string :name
      t.string :ip
      t.string :site
      t.string :environment
      t.string :operating_system
      t.string :operating_system_flavour
      t.string :description
      t.string :responsible

      t.timestamps
    end
  end

  def self.down
    drop_table :systems
  end
end
