class SetApiKeyDefaultToNil < ActiveRecord::Migration
  def self.up
    change_column_default(:users, :api_key, nil)
  end

  def self.down
  end
end
