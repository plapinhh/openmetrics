class AddJobKeyToIpLookup < ActiveRecord::Migration
  def self.up
    add_column :ip_lookups, :job_key, :string
  end

  def self.down
    remove_column :ip_lookups, :job_key
  end
end
