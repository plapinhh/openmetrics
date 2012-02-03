class AddFqdnToSystem < ActiveRecord::Migration
  def self.up
    add_column :systems, :fqdn, :string
  end

  def self.down
    remove_column :systems, :fqdn
  end
end
