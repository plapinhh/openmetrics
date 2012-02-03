class AddMuninGroupToSystemHistories < ActiveRecord::Migration
  def self.up
    add_column :system_histories, :munin_group, :string
  end

  def self.down
    remove_column :system_histories, :munin_group
  end
end
