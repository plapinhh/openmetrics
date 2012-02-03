class AddLastChangedIdToService < ActiveRecord::Migration
  def self.up
    add_column :services, :last_change_user_id, :integer
  end

  def self.down
    remove_column :services, :last_change_user_id
  end
end
