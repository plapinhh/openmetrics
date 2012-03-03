class AddUidToDashboards < ActiveRecord::Migration
  def self.up
        add_column :dashboards, :user_id, :integer
  end

  def self.down
  remove_column :dashboards, :user_id
  end
end
