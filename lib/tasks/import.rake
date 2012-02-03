# 
# To change this template, choose Tools | Templates
# and open the template in the editor.
 
require 'faster_csv'


namespace :relist do
  desc "dummy"
  task(:dummy => :environment) do
    System.create(:name=>"test")
  end
  
  #############################################################################
  
  desc "import old data from csv"
  task(:import_systems => :environment) do
    if ENV['filename'].nil?
        puts "\nUSAGE:"
        puts "rake relist:import_systems filename=<filename>"
        puts
        exit false
      end
      unless File.exists?(ENV['filename'])
        puts "\nCSV file '#{ENV['filename']}' not found."
        puts "\nUSAGE:"
        puts "rake relist:import_systems filename=<filename>"
        puts
        exit false
      end
      
      # File exists, lets get started:
      
      # We are converting a CSV File with 39 Cols to our fit in our Database
      
      # Load the File
      puts "IMPORTANT:"
      puts "Please assert that you used | for column separation and \" as quote_char"
      
      row_counter = 0
      
      
      FasterCSV.foreach(ENV['filename'],:col_sep => "|",:quote_char => "\"",:headers => false, :converters => :all) do |row| 
        row_counter = row_counter + 1
      
        name = ""
        ip = ""
        site = ""
        environment = ""
        operating_system = ""
        operating_system_flavour = ""
        description = ""
        responsible = ""
        former_id = 0
      
        if (row[0] != nil)
          former_id = row[0]  
        end
        
        if (row[1] != nil)
          name = row[1]  
        end
        
        if (row[2] != nil)
          ip = row[2]  
        end
        
        if (row[3] != nil)
          site = row[3]  
        end
        
        if (row[4] != nil)
          environment = row[4]  
        end
        if (row[5] != nil)
          operating_system = row[5]  
        end
        if (row[6] != nil)
          operating_system_flavour = row[6]  
        end
        if (row[7] != nil)
          description = row[7]  
        end
        if (row[8] != nil)
          responsible = row[8]  
        end
      
        unless System.exists?(former_id)
          new_system = System.new do |r|
            r.id = former_id
            r.save
          end
        else
          new_system = System.find(former_id)
        end  
      
      
        new_system.update_attributes(:name=>name,:ip=>ip,:site=>site,:environment=>environment,:operating_system=>operating_system,:operating_system_flavour=>operating_system_flavour,:description=>description,:responsible=>responsible)
        
        # recreate old id
        new_system.id = former_id
      
        new_system.save(false)
        puts new_system.inspect
      end # CSV-Iteration
      #
      # reset Systems ID sequence - otherwise the sequence is out of sync
      # with our actual IDs, and we might get duplicate key violations when inserting
      # new systems
      if ActiveRecord::Base.connection.respond_to?(:reset_pk_sequence!)
        puts "resetting primary key sequence for systems"
        ActiveRecord::Base.connection.reset_pk_sequence!('systems')
      else
        puts "WARNING: cannot reset primary key sequence automatically - you will have to do this by yourself!"
      end
      
      puts "Task done"
    
  end # task
  
  #############################################################################
  
  desc "import old data from csv"
  task(:import_services => :environment) do
    if ENV['filename'].nil?
        puts "\nUSAGE:"
        puts "rake relist:import_services   filename=<filename>"
        puts
        exit false
      end
      unless File.exists?(ENV['filename'])
        puts "\nCSV file '#{ENV['filename']}' not found."
        puts "\nUSAGE:"
        puts "rake relist:import_services filename=<filename>"
        puts
        exit false
      end
      
      # File exists, lets get started:
  
      
      # Load the File
      puts "IMPORTANT:"
      puts "Please assert that you used | for column separation and \" as quote_char"
      
      row_counter = 0
      
      
      FasterCSV.foreach(ENV['filename'],:col_sep => "|",:quote_char => "\"",:headers => false, :converters => :all) do |row| 
        row_counter = row_counter + 1
      
        name = ""
        typ = ""
        group = ""
        description = ""
        dns_name = ""
        system_id = ""
        description = ""
        former_id = ""
      
        if (row[0] != nil)
          former_id = row[0]  
        end
        
        if (row[1] != nil)
          name = row[1]  
        end
        
        if (row[2] != nil)
          system_id = row[2]  
        end
        
        if (row[3] != nil)
          dns_name = row[3]  
        end
        
        if (row[4] != nil)
          typ = row[4]  
        end
        if (row[5] != nil)
          group = row[5]  
        end
        if (row[6] != nil)
          description = row[6]  
        end
        
        unless Service.exists?(former_id)
          new_service = Service.new do |r|
            r.id = former_id
            r.save
          end
        else
          new_service = Service.find(former_id)
        end  
      
      
        new_service.update_attributes(:name => name, :dns_name=>dns_name, :typ=>typ, :group=>group, :description=>description)
        #new_system = System.create(:name=>name,:ip=>ip,:site=>site,:environment=>environment,:operating_system=>operating_system,:operating_system_flavour=>operating_system_flavour,:description=>description,:responsible=>responsible)
        
        new_service.id = former_id
      
      
        new_service.save
      
        new_running_service = RunningService.create(:system_id=>system_id,:service_id=>new_service.id)
      
        puts new_service.inspect
      end # CSV-Iteration
      
      # reset Services ID sequence - otherwise the sequence is out of sync
      # with our actual IDs, and we might get duplicate key violations when inserting
      # new services
      if ActiveRecord::Base.connection.respond_to?(:reset_pk_sequence!)
        puts "resetting primary key sequence for services"
        ActiveRecord::Base.connection.reset_pk_sequence!('services')
      else
        puts "WARNING: cannot reset primary key sequence automatically - you will have to do this by yourself!"
      end
      
      puts "Task done"
    
    
  end # task
  
  #############################################################################
  
  desc "import old data from csv"
  task(:import_crontab_days_of_month => :environment) do
    if ENV['filename'].nil?
        puts "\nUSAGE:"
        puts "rake relist:import_crontab_days_of_month   filename=<filename>"
        puts
        exit false
      end
      unless File.exists?(ENV['filename'])
        puts "\nCSV file '#{ENV['filename']}' not found."
        puts "\nUSAGE:"
        puts "rake relist:import_crontab_days_of_month filename=<filename>"
        puts
        exit false
      end
      
      # File exists, lets get started:
      
      # Load the File
      puts "IMPORTANT:"
      puts "Please assert that you used | for column separation and \" as quote_char"
      
      row_counter = 0
      
      
      FasterCSV.foreach(ENV['filename'],:col_sep => "|",:quote_char => "\"",:headers => false, :converters => :all) do |row| 
        row_counter = row_counter + 1
      
        crontab_job_id = 0
        day_of_month = 0
        timestamp = 0
        isnew = false
      
        if (row[0] != nil)
          crontab_job_id = row[0]  
        end
        
        if (row[1] != nil)
          day_of_month = row[1]  
        end
        
        if (row[2] != nil)
          timestamp = row[2]  
        end
        
        if (row[3] != nil)
          isnew = row[3]  
        end
         
        new_crontab_days_of_month = CrontabDaysOfMonth.new do |r|   
          r.save
        end
      
      
        new_crontab_days_of_month.update_attributes(:crontab_job_id=>crontab_job_id,
                                                    :day_of_month=>day_of_month,
                                                    :timestamp=>timestamp,
                                                    :isnew=>isnew)
        
           
        new_crontab_days_of_month.save
          
        puts new_crontab_days_of_month.inspect
      end # CSV-Iteration
      
      
      puts "Task done"
    
    
  end # task
  
  #############################################################################
  
  desc "import old data from csv"
  task(:import_crontab_days_of_week => :environment) do
    if ENV['filename'].nil?
        puts "\nUSAGE:"
        puts "rake relist:import_crontab_days_of_week   filename=<filename>"
        puts
        exit false
      end
      unless File.exists?(ENV['filename'])
        puts "\nCSV file '#{ENV['filename']}' not found."
        puts "\nUSAGE:"
        puts "rake relist:import_crontab_days_of_week filename=<filename>"
        puts
        exit false
      end
      
      # File exists, lets get started:
      
      # Load the File
      puts "IMPORTANT:"
      puts "Please assert that you used | for column separation and \" as quote_char"
      
      row_counter = 0
      
      
      FasterCSV.foreach(ENV['filename'],:col_sep => "|",:quote_char => "\"",:headers => false, :converters => :all) do |row| 
        row_counter = row_counter + 1
      
        crontab_job_id = 0
        day_of_week = 0
        timestamp = 0
        isnew = false
      
        if (row[0] != nil)
          crontab_job_id = row[0]  
        end
        
        if (row[1] != nil)
          day_of_week = row[1]  
        end
        
        if (row[2] != nil)
          timestamp = row[2]  
        end
        
        if (row[3] != nil)
          isnew = row[3]  
        end
         
        new_crontab_days_of_week = CrontabDaysOfWeek.new do |r|   
          r.save
        end
      
      
        new_crontab_days_of_week.update_attributes(:crontab_job_id=>crontab_job_id,
                                                    :day_of_week=>day_of_week,
                                                    :timestamp=>timestamp,
                                                    :isnew=>isnew)
        
           
        new_crontab_days_of_week.save
          
        puts new_crontab_days_of_week.inspect
      end # CSV-Iteration
      
      
      puts "Task done"
    
    
  end # task
  
  #############################################################################
  
  desc "import old data from csv"
  task(:import_crontab_hours => :environment) do
    if ENV['filename'].nil?
        puts "\nUSAGE:"
        puts "rake relist:import_crontab_hours   filename=<filename>"
        puts
        exit false
      end
      unless File.exists?(ENV['filename'])
        puts "\nCSV file '#{ENV['filename']}' not found."
        puts "\nUSAGE:"
        puts "rake relist:import_crontab_hours filename=<filename>"
        puts
        exit false
      end
      
      # File exists, lets get started:
      
      # Load the File
      puts "IMPORTANT:"
      puts "Please assert that you used | for column separation and \" as quote_char"
      
      row_counter = 0
      
      
      FasterCSV.foreach(ENV['filename'],:col_sep => "|",:quote_char => "\"",:headers => false, :converters => :all) do |row| 
        row_counter = row_counter + 1
      
        crontab_job_id = 0
        hour = 0
        timestamp = 0
        isnew = false
      
        if (row[0] != nil)
          crontab_job_id = row[0]  
        end
        
        if (row[1] != nil)
          hour = row[1]  
        end
        
        if (row[2] != nil)
          timestamp = row[2]  
        end
        
        if (row[3] != nil)
          isnew = row[3]  
        end
         
        new_crontab_hours = CrontabHour.new do |r|   
          r.save
        end
      
      
        new_crontab_hours.update_attributes(:crontab_job_id=>crontab_job_id,
                                                    :hour=>hour,
                                                    :timestamp=>timestamp,
                                                    :isnew=>isnew)
        
           
        new_crontab_hours.save
          
        puts new_crontab_hours.inspect
      end # CSV-Iteration
      
      
      puts "Task done"
    
    
  end # task
  
  #############################################################################
  
  desc "import old data from csv"
  task(:import_crontab_mins => :environment) do
    if ENV['filename'].nil?
        puts "\nUSAGE:"
        puts "rake relist:import_crontab_mins   filename=<filename>"
        puts
        exit false
      end
      unless File.exists?(ENV['filename'])
        puts "\nCSV file '#{ENV['filename']}' not found."
        puts "\nUSAGE:"
        puts "rake relist:import_crontab_mins filename=<filename>"
        puts
        exit false
      end
      
      # File exists, lets get started:
      
      # Load the File
      puts "IMPORTANT:"
      puts "Please assert that you used | for column separation and \" as quote_char"
      
      row_counter = 0
      
      
      FasterCSV.foreach(ENV['filename'],:col_sep => "|",:quote_char => "\"",:headers => false, :converters => :all) do |row| 
        row_counter = row_counter + 1
      
        crontab_job_id = 0
        min = 0
        timestamp = 0
        isnew = false
      
        if (row[0] != nil)
          crontab_job_id = row[0]  
        end
        
        if (row[1] != nil)
          min = row[1]  
        end
        
        if (row[2] != nil)
          timestamp = row[2]  
        end
        
        if (row[3] != nil)
          isnew = row[3]  
        end
         
        new_crontab_mins = CrontabMin.new do |r|   
          r.save
        end
      
      
        new_crontab_mins.update_attributes(:crontab_job_id=>crontab_job_id,
                                                    :min=>min,
                                                    :timestamp=>timestamp,
                                                    :isnew=>isnew)
        
           
        new_crontab_mins.save
          
        puts new_crontab_mins.inspect
      end # CSV-Iteration
      
      
      puts "Task done"
    
    
  end # task
  
  #############################################################################
  
  desc "import old data from csv"
  task(:import_crontab_months => :environment) do
    if ENV['filename'].nil?
        puts "\nUSAGE:"
        puts "rake relist:import_crontab_months   filename=<filename>"
        puts
        exit false
      end
      unless File.exists?(ENV['filename'])
        puts "\nCSV file '#{ENV['filename']}' not found."
        puts "\nUSAGE:"
        puts "rake relist:import_crontab_months filename=<filename>"
        puts
        exit false
      end
      
      # File exists, lets get started:
      
      # Load the File
      puts "IMPORTANT:"
      puts "Please assert that you used | for column separation and \" as quote_char"
      
      row_counter = 0
      
      
      FasterCSV.foreach(ENV['filename'],:col_sep => "|",:quote_char => "\"",:headers => false, :converters => :all) do |row| 
        row_counter = row_counter + 1
      
        crontab_job_id = 0
        month = 0
        timestamp = 0
        isnew = false
      
        if (row[0] != nil)
          crontab_job_id = row[0]  
        end
        
        if (row[1] != nil)
          month = row[1]  
        end
        
        if (row[2] != nil)
          timestamp = row[2]  
        end
        
        if (row[3] != nil)
          isnew = row[3]  
        end
         
        new_crontab_months = CrontabMonth.new do |r|   
          r.save
        end
      
      
        new_crontab_months.update_attributes(:crontab_job_id=>crontab_job_id,
                                                    :month=>month,
                                                    :timestamp=>timestamp,
                                                    :isnew=>isnew)
        
           
        new_crontab_months.save
          
        puts new_crontab_months.inspect
      end # CSV-Iteration
      
      
      puts "Task done"
    
    
  end # task
  
  #############################################################################
  
  desc "import old data from csv"
  task(:import_crontab_jobs => :environment) do
    if ENV['filename'].nil?
        puts "\nUSAGE:"
        puts "rake relist:import_crontab_jobs   filename=<filename>"
        puts
        exit false
      end
      unless File.exists?(ENV['filename'])
        puts "\nCSV file '#{ENV['filename']}' not found."
        puts "\nUSAGE:"
        puts "rake relist:import_crontab_jobs filename=<filename>"
        puts
        exit false
      end
      
      # File exists, lets get started:
      
      # Load the File
      puts "IMPORTANT:"
      puts "Please assert that you used | for column separation and \" as quote_char"
      
      row_counter = 0
      
      
      FasterCSV.foreach(ENV['filename'],:col_sep => "|",:quote_char => "\"",:headers => false, :converters => :all) do |row| 
        row_counter = row_counter + 1
      
      
        former_id = 0
        crontab_cmd_id = 0
        system_id = 0
        account = ""
        time_field = ""
        timestamp = ""
        isnew = false
        
        if (row[0] != nil)
          former_id = row[0]  
        end
        
        if (row[1] != nil)
          crontab_cmd_id = row[1]  
        end
        
        if (row[2] != nil)
          system_id = row[2]  
        end
        
        if (row[3] != nil)
          account = row[3]  
        end
        
        if (row[4] != nil)
          time_field = row[4]  
        end
        
        if (row[5] != nil)
          timestamp = row[5]  
        end
        
        if (row[6] != nil)
          isnew = row[6]  
        end
        

        unless CrontabJob.exists?(former_id)
          new_crontab_job = CrontabJob.new do |r|
            r.id = former_id
            r.save
          end
        else
          new_crontab_job = CrontabJob.find(former_id)
        end  
      
      
        
        
        new_crontab_job.update_attributes(:crontab_cmd_id=>crontab_cmd_id,
                                          :system_id=>system_id,
                                          :account=>account,
                                          :time_field=>time_field,
                                          :timestamp=>timestamp,
                                          :isnew=>isnew)
      
        # recreate old id
        new_crontab_job.id = former_id
      
        new_crontab_job.save(false)
        puts new_crontab_job.inspect
      end # CSV-Iteration
      #
      # reset CrontabJobs ID sequence - otherwise the sequence is out of sync
      # with our actual IDs, and we might get duplicate key violations when inserting
      # new crontabjobs
      if ActiveRecord::Base.connection.respond_to?(:reset_pk_sequence!)
        puts "resetting primary key sequence for crontab_jobs"
        ActiveRecord::Base.connection.reset_pk_sequence!('crontab_jobs')
      else
        puts "WARNING: cannot reset primary key sequence automatically - you will have to do this by yourself!"
      end
       
      puts "Task done"
    
    
  end # task
  
  #############################################################################
  
  desc "import old data from csv"
  task(:import_crontab_cmds => :environment) do
    if ENV['filename'].nil?
        puts "\nUSAGE:"
        puts "rake relist:import_crontab_cmds   filename=<filename>"
        puts
        exit false
      end
      unless File.exists?(ENV['filename'])
        puts "\nCSV file '#{ENV['filename']}' not found."
        puts "\nUSAGE:"
        puts "rake relist:import_crontab_cmds filename=<filename>"
        puts
        exit false
      end
      
      # File exists, lets get started:
      
      # Load the File
      puts "IMPORTANT:"
      puts "Please assert that you used | for column separation and \# as quote_char"
      
      row_counter = 0
      
      
      FasterCSV.foreach(ENV['filename'],:col_sep => "|",:quote_char => "\#",:headers => false, :converters => :all) do |row| 
        row_counter = row_counter + 1
      
      
        former_id = 0
        command=""
        
        if (row[0] != nil)
          former_id = row[0]  
        end
        
        if (row[1] != nil)
          command = row[1]  
        end
        

        unless CrontabCmd.exists?(former_id)
          new_crontab_cmd = CrontabCmd.new do |r|
            r.id = former_id
            r.save
          end
        else
          new_crontab_cmd = CrontabCmd.find(former_id)
        end  
      
      
        
        
        new_crontab_cmd.update_attributes(:command=>command)
      
        # recreate old id
        new_crontab_cmd.id = former_id
      
        new_crontab_cmd.save(false)
        puts new_crontab_cmd.inspect
      end # CSV-Iteration
      #
      # reset CrontabCmds ID sequence - otherwise the sequence is out of sync
      # with our actual IDs, and we might get duplicate key violations when inserting
      # new crontabcmds
      if ActiveRecord::Base.connection.respond_to?(:reset_pk_sequence!)
        puts "resetting primary key sequence for crontab_cmds"
        ActiveRecord::Base.connection.reset_pk_sequence!('crontab_cmds')
      else
        puts "WARNING: cannot reset primary key sequence automatically - you will have to do this by yourself!"
      end
       
      puts "Task done"
    
    
  end # task
  
  #############################################################################
  
  desc "import old data from csv"
  task(:import_servers_and_services => :environment) do
    if ENV['filename'].nil?
        puts "\nUSAGE:"
        puts "rake relist:import_servers_and_services   filename=<filename>"
        puts
        exit false
      end
      unless File.exists?(ENV['filename'])
        puts "\nCSV file '#{ENV['filename']}' not found."
        puts "\nUSAGE:"
        puts "rake relist:import_servers_and_services filename=<filename>"
        puts
        exit false
      end
      
      # File exists, lets get started:
      
      # Load the File
      puts "IMPORTANT:"
      puts "Please assert that you used | for column separation and \# as quote_char"
      
      row_counter = 0
      
      
      FasterCSV.foreach(ENV['filename'],:col_sep => "|",:quote_char => "\"",:headers => false, :converters => :all) do |row| 
        row_counter = row_counter + 1
      
      
        machine = ""
        nagios_name = ""
        nagios_alias = ""
        ip = ""
        dns_alias =""
        site = ""
        environment = ""
        service = ""
        description = ""
        data_exchange = ""
        protocol = ""
        port = ""
        serverid = 0
        hardware = ""
        perl_path = ""
        perl_arch = ""
        uname = ""
        data = ""
        atanas = ""
        inventar_no = ""
        spacenet_cust = ""
        owner = ""
        former_id = 0
        system_id = 0
        
        if (row[0] != nil)
          former_id = row[0]
        end
        if (row[1] != nil)
          machine = row [1]
        end
        
        if (row[2] != nil)
          nagios_name = row[2]
        end
        
        if (row[3] != nil)
          nagios_alias = row[3]
        end
        
        if (row[4] != nil)
          ip = row[4]
        end
        
        if (row[5] != nil)
          dns_alias = row[5]
        end
        
        if (row[6] != nil)
          site = row[6]
        end
        
        if (row[7] != nil)
          environment = row[7]
        end
      
        if (row[8] != nil)
          service = row[8]
        end
        
        if (row[9] != nil)
          description = row[9]
        end
        
        if (row[10] != nil)
          data_exchange = row[10]
        end
        
        if (row[11] != nil)
          protocol = row[11]
        end
        
        if (row[12] != nil)
          port = row[12]
        end
        
        if (row[13] != nil)
          serverid = row[13]
        end
        
        if (row[14] != nil)
          hardware = row[14]
        end
        
      if (row[15] != nil)
          perl_path = row[15]
        end
        if (row[16] != nil)
          perl_version = row[16]
        end
        if (row[17] != nil)
          perl_arch = row[17]
        end
        
      if (row[18] != nil)
          uname = row[18]
        end
        if (row[19] != nil)
          data = row[19]
        end
        if (row[20] != nil)
          atanas = row[20]
        end
        if (row[21] != nil)
          inventar_no = row[21]
        end
        if (row[22] != nil)
          spacenet_cust = row[22]
        end
        if (row[23] != nil)
          owner = row[23]
        end
        
        if (row[24] != nil)
          system_id = row[24]
        end
      
      
        unless ServersAndService.exists?(former_id)
          new_sas = ServersAndService.new do |r|
            r.id = former_id
            r.save
          end
        else
          new_sas = ServersAndService.find(former_id)
        end  
      
      
        
        
        new_sas.update_attributes(:machine => machine,
          :nagios_name => nagios_name,
          :nagios_alias => nagios_alias,
          :ip => ip,
          :dns_alias => dns_alias,
          :site => site,
          :environment => environment,
          :service => service,
          :description => description,
          :data_exchange => data_exchange,
          :protocol => protocol,
          :port => port,
          :serverid => serverid,
          :hardware => hardware,
          :perl_path => perl_path,
          :perl_version => perl_version,
          :perl_arch => perl_arch,
          :uname => uname,
          :data_exchange => data,
          :atanas => atanas,
          :inventar_no => inventar_no,
          :spacenet_cust => spacenet_cust,
          :owner => owner,
          :system_id => system_id)
      
      
        # recreate old id
        new_sas.id = former_id
      
        new_sas.save(false)
        puts new_sas.inspect
      end # CSV-Iteration
      #
      # reset CrontabCmds ID sequence - otherwise the sequence is out of sync
      # with our actual IDs, and we might get duplicate key violations when inserting
      # new servers_and_Services
      if ActiveRecord::Base.connection.respond_to?(:reset_pk_sequence!)
        puts "resetting primary key sequence for servers_and_services"
        ActiveRecord::Base.connection.reset_pk_sequence!('servers_and_services')
      else
        puts "WARNING: cannot reset primary key sequence automatically - you will have to do this by yourself!"
      end
       
      puts "Task done"
    
    
  end # task
  
  #############################################################################
  
  desc "import old data from csv"
  task(:import_nagios_systems => :environment) do
    if ENV['filename'].nil?
        puts "\nUSAGE:"
        puts "rake relist:import_nagios_systems   filename=<filename>"
        puts
        exit false
      end
      unless File.exists?(ENV['filename'])
        puts "\nCSV file '#{ENV['filename']}' not found."
        puts "\nUSAGE:"
        puts "rake relist:import_nagios_systems filename=<filename>"
        puts
        exit false
      end
      
      # File exists, lets get started:
      
      # Load the File
      puts "IMPORTANT:"
      puts "Please assert that you used | for column separation and \# as quote_char"
      
      row_counter = 0
      
      
      FasterCSV.foreach(ENV['filename'],:col_sep => "|",:quote_char => "\#",:headers => false, :converters => :all) do |row| 
        row_counter = row_counter + 1
      
      
        former_id = 0
        system_id = 0
        name = ""
        _alias = ""
        parent_id = 0
        contact_groups = ""
       
        
        if (row[0] != nil)
          former_id = row[0]  
        end
        
        if (row[1] != nil)
          system_id = row[1]  
        end
        
        if (row[2] != nil)
          name = row[2]  
        end
        if (row[3] != nil)
          _alias = row[3]  
        end
        if (row[4] != nil)
          parent_id = row[4]  
        end
        if (row[5] != nil)
          contact_groups = row[5]  
        end

        unless NagiosSystem.exists?(former_id)
          new_nagios_system = NagiosSystem.new do |r|
            r.id = former_id
            r.save
          end
        else
          new_nagios_system = NagiosSystem.find(former_id)
        end  
      
      
        
        
        new_nagios_system.update_attributes(:system_id => system_id, :name => name, :alias => _alias, :parent_id=>parent_id,:contact_groups=>contact_groups)
      
        # recreate old id
        new_nagios_system.id = former_id
      
        new_nagios_system.save(false)
        puts new_nagios_system.inspect
      end # CSV-Iteration
      #
      # reset CrontabCmds ID sequence - otherwise the sequence is out of sync
      # with our actual IDs, and we might get duplicate key violations when inserting
      # new nagios_systems
      if ActiveRecord::Base.connection.respond_to?(:reset_pk_sequence!)
        puts "resetting primary key sequence for nagios_systems"
        ActiveRecord::Base.connection.reset_pk_sequence!('nagios_systems')
      else
        puts "WARNING: cannot reset primary key sequence automatically - you will have to do this by yourself!"
      end
       
      puts "Task done"
    
    
  end # task
  
end