class AddTypeToServiceHistories < ActiveRecord::Migration
  def self.up
    add_column :service_histories, :type, :string
  end

  def self.down
    remove_column :service_histories, :type
  end
end