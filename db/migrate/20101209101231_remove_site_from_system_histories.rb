class RemoveSiteFromSystemHistories < ActiveRecord::Migration
  def self.up
    remove_column :system_histories, :site
  end

  def self.down
    add_column :system_histories, :site, :string
  end
end
