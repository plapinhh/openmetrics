class AddLastChangedIdToSystem < ActiveRecord::Migration
  def self.up
    add_column :systems, :last_change_user_id, :integer
  end

  def self.down
    remove_column :systems, :last_change_user_id
  end
end
