class AddPubkeyToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :sshpubkey, :text

    #Create an admin
    @user = User.new()
    @user.update_attributes!(:login => 'admin',
                             :password => 'adminadmin',
                             :password_confirmation => 'adminadmin',
                             :email => "admin@example.com")


    puts "Creating master role..."
    Role.create(:rolename => 'master') # this rolename is case sensitive and required!
    puts "... master role created"

    # We assume Admin has ID=1 and is already present
    # give him the master role!
    puts "Giving admin (UserID=1) the master Role..."
    @admin = User.find(1)
    @admin.roles << Role.find_by_rolename('master')
    @admin.save!
    puts "... admin now has the master role"
  end

  def self.down
    remove_column :users, :sshpubkey
  end
end
