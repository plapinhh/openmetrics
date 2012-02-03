# 
# To change this template, choose Tools | Templates
# and open the template in the editor.



namespace :openmetrics do
  
  desc "Creates the AdminUser and the Roles"
  task(:setup => :environment) do
      
        puts "\nCreating admin user"
        @user = User.new()
        @user.update_attributes!(:login => 'admin',
                             :password => 'adminadmin',
                             :password_confirmation => 'adminadmin',
                             :email => "admin@example.com")
        puts "\nCreating master role..."
        Role.create(:rolename => 'master') # this rolename is case sensitive and required!
        puts "... master role created"

        # We assume Admin has ID=1 and is already present
        # give him the master role!
        puts "\Giving admin (UserID=1) the master Role..."
        @admin = User.find(1)
        @admin.roles << Role.find_by_rolename('master')
        @admin.save!
        puts "... admin now has the master role"

        puts "setup complete."
        puts "\nYou can log into openmetrics with user:'admin' pw:'adminadmin' now!"
      
  end #task
end
