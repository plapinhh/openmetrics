class AddSystemIdToSystemHistory < ActiveRecord::Migration
  def self.up
    add_column :system_histories, :system_id, :integer
  end

  def self.down
    remove_column :system_histories, :system_id
  end
end
