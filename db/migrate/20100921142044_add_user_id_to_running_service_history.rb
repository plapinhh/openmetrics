class AddUserIdToRunningServiceHistory < ActiveRecord::Migration
  def self.up
    add_column :running_service_histories, :user_id, :integer
  end

  def self.down
    remove_column :running_service_histories, :user_id
  end
end
