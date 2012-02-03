class AddTargetToIpLookup < ActiveRecord::Migration
  def self.up
    add_column :ip_lookups, :target, :string
  end

  def self.down
    remove_column :ip_lookups, :target
  end
end
