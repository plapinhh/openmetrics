namespace :openmentrics do

  #TODO some services, e.g. collectd_service should be extended with "type" attribute
  
  desc "Creates typical services, e.g. SSHD, Apache, PostgreSQL..."
  task(:service_setup => :environment) do

        puts "Creating service 'Apache2'"
        @service = Service.new(
          :name => 'Apache2',
          :description => 'HTTP server')
        @service.save!

        puts "Creating service 'Collectd'"
        @service = Service.new(
          :name => 'Collectd',
          :description => 'System statistics collection daemon')
        @service.save!

        puts "Creating service 'Memcached'"
        @service = Service.new(
          :name => 'Memcached',
          :description => 'memory object caching daemon')
        @service.save!

        puts "Creating service 'Nginx'"
        @service = Service.new(
          :name => 'Nginx',
          :description => 'HTTP and caching reverse proxy server')
        @service.save!

        puts "Creating service 'PostgreSQL'"
        @service = Service.new(
          :name => 'PostgreSQL',
          :description => 'Object-relational database management system')
        @service.save!

        puts "Creating service 'SSHD'"
        @service = Service.new(
          :name => 'SSHD',
          :description => 'Secure shell daemon')
        @service.save!

        puts "Creating service 'Tomcat'"
        @service = Service.new(
          :name => 'Tomcat',
          :description => 'Java servlet container')
        @service.save!



        puts "\nService setup complete!"
      
  end #task
end
