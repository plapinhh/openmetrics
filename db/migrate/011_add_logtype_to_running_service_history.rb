class AddLogtypeToRunningServiceHistory < ActiveRecord::Migration
  def self.up
    add_column :running_service_histories, :logtype, :string
  end

  def self.down
    remove_column :running_service_histories, :logtype
  end
end
