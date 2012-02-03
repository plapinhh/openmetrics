class RenameUserIdInHistories < ActiveRecord::Migration
  def self.up
    remove_column :running_service_histories, :user_id
    remove_column :service_histories, :user_id
    remove_column :system_histories, :user_id
    add_column :running_service_histories, :last_change_user_id, :integer
    add_column :service_histories, :last_change_user_id, :integer
    add_column :system_histories, :last_change_user_id, :integer
  end

  def self.down
  end
end
