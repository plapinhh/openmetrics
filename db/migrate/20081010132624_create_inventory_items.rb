class CreateInventoryItems < ActiveRecord::Migration
  def self.up
    create_table :inventory_items do |t|
      t.integer :system_id
      t.string :owner
      t.date :contract_start_date
      t.date :minimum_contract_running_date
      t.string :initial_cost
      t.string :monthly_cost
      t.string :inv_id_parship
      t.string :inv_id_provider
      t.text :description

      t.timestamps
    end
  end

  def self.down
    drop_table :inventory_items
  end
end
