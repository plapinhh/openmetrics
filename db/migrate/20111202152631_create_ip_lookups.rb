class CreateIpLookups < ActiveRecord::Migration
  def self.up
    create_table :ip_lookups do |t|
      t.integer :user_id
      t.text :scanresult

      t.timestamps
    end
  end

  def self.down
    drop_table :ip_lookups
  end
end
