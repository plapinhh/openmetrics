class AddUserIdToSystemHistory < ActiveRecord::Migration
  def self.up
    add_column :system_histories, :user_id, :integer
  end

  def self.down
    remove_column :system_histories, :user_id
  end
end
