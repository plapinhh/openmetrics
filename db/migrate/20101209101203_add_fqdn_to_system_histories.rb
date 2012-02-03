class AddFqdnToSystemHistories < ActiveRecord::Migration
  def self.up
    add_column :system_histories, :fqdn, :string
  end

  def self.down
    remove_column :system_histories, :fqdn
  end
end
