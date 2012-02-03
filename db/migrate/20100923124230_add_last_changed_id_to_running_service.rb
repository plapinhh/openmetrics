class AddLastChangedIdToRunningService < ActiveRecord::Migration
  def self.up
    add_column :running_services, :last_change_user_id, :integer
  end

  def self.down
    remove_column :running_services, :last_change_user_id
  end
end
