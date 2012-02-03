class AddUserIdToServiceHistory < ActiveRecord::Migration
  def self.up
    add_column :service_histories, :user_id, :integer
  end

  def self.down
    remove_column :service_histories, :user_id
  end
end
