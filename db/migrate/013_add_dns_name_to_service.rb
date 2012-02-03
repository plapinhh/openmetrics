class AddDnsNameToService < ActiveRecord::Migration
  def self.up
    add_column :services, :dns_name, :string
  end

  def self.down
    remove_column :services, :dns_name
  end
end
