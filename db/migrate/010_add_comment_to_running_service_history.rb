class AddCommentToRunningServiceHistory < ActiveRecord::Migration
  def self.up
    add_column :running_service_histories, :comment, :string
  end

  def self.down
    remove_column :running_service_histories, :comment
  end
end
