class AddMuninGroupToSystem < ActiveRecord::Migration
  def self.up
  end

  def self.up
    add_column :systems, :munin_group, :text
  end

  def self.down
  end
end
