class RenameResponsibleColumnToSshUser < ActiveRecord::Migration
  def self.up
    rename_column :systems, :responsible, :sshuser
    rename_column :system_histories, :responsible, :sshuser
  end

  def self.down
    rename_column :systems, :sshuser, :responsible
    rename_column :system_histories, :sshuser, :responsible
  end
end
